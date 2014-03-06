require 'capybara'
require 'capybara-webkit'
require 'capybara-user_agent'
require 'net/http' 
require 'open-uri'
require 'trollop'

LONG_WAIT = 60
SHORT_WAIT = 5

Capybara.current_driver = :selenium
# Capybara.current_driver = :webkit
# Capybara.javascript_driver = :webkit
Capybara.default_wait_time = LONG_WAIT

# Need to interact with hidden form field for Kayak ID
Capybara.ignore_hidden_elements = false

# When searching for an airport showing up on the page, we don't care if it's ambiguous
Capybara.match = :first

# Don't need our own server, I don't think...
Capybara.run_server = false

module Kayak

  STRIKES = 'strikes.dat'
  ROUTES = 'routes.dat'
  KAYAK_CODES = 'kayak_codes.dat'

  def self.codes
    @codes ||= {}
  end

  def self.strikes
    @strikes ||= []
  end

  def self.load_strikes(filename)
    File.open(filename, 'rb').read.lines.each do |l|
      src,dst = l.strip.split(',')
      strikes << { src: src, dst: dst }
    end
    puts "Loaded #{strikes.length} strikes"
  end

  def self.load_kayak_codes(filename)
    File.open(filename, 'rb').read.lines.each do |l|
      iata,code = l.strip.split(',')
      codes[iata.to_sym] = code
    end
    puts "Loaded #{codes.length} Kayak codes"
  end

  class Query
    include Capybara::DSL
    include Capybara::UserAgent::DSL

    def prices
      @prices ||= []
    end

    def codes
      @codes ||= Kayak.codes
    end

    def strikes
      @strikes ||= Kayak.strikes
    end

    def initialize
      Kayak.load_kayak_codes KAYAK_CODES
      Kayak.load_strikes STRIKES
    end

    def get_code(iata)
      code = codes[iata.to_sym]
      return if code

      visit 'http://www.kayak.com/flights'
      fill_in 'origin', with: iata
      find('li.ap')
      find('#origin').native.send_keys :tab
      code = find(:xpath, "//input[@id='origincode']").value.strip.split('/')[1]

      throw "Unable to find Kayak code for #{iata}" if code.empty?

      puts "Found Kayak code #{code} for #{iata}"      
      codes[iata.to_sym] = code
      open(KAYAK_CODES, 'a') { |f| f.puts "#{iata},#{code}" }

      return code
    end

    def run_search
      # Check that we have codes for all strikes
      strikes.each do |s|
        get_code s[:src]
        get_code s[:dst]
      end
    end

    def test_strike(itin)

      Capybara.current_session.reset!

      target = 'http://www.ca.kayak.com/flights?mc=y'
      visit target

      # Fill in the form (works in Selenium!)
      # Fill with blanks first to stop auto-filling when moving through the form

      fill_in 'origin0', with: ''
      fill_in 'origin0', with: itin[:oa]
      Capybara.current_session.driver.execute_script("return document.getElementById('origincode0').value = '#{get_code itin[:oa]}';")

      fill_in 'destination0', with: ''
      fill_in 'destination0', with: itin[:da]
      Capybara.current_session.driver.execute_script("return document.getElementById('destcode0').value = '#{get_code itin[:da]}';")
      
      fill_in 'depart_date0', with: itin[:od].strftime('%d/%m/%Y')

      fill_in 'origin1', with: ''
      fill_in 'origin1', with: itin[:da]
      Capybara.current_session.driver.execute_script("return document.getElementById('origincode1').value = '#{get_code itin[:da]}';")

      fill_in 'destination1', with: ''
      fill_in 'destination1', with: itin[:oa]
      Capybara.current_session.driver.execute_script("return document.getElementById('destcode1').value = '#{get_code itin[:oa]}';")

      fill_in 'depart_date1', with: itin[:dd].strftime('%d/%m/%Y')

      # Don't necessarily need strike info
      if itin[:ssrc] && itin[:sdst] && itin[:sd]
        fill_in 'origin2', with: ''
        fill_in 'origin2', with: itin[:ssrc]
        Capybara.current_session.driver.execute_script("return document.getElementById('origincode2').value = '#{get_code itin[:ssrc]}';")
        
        fill_in 'destination2', with: ''
        fill_in 'destination2', with: itin[:sdst]
        Capybara.current_session.driver.execute_script("return document.getElementById('destcode2').value = '#{get_code itin[:sdst]}';")

        fill_in 'depart_date2', with: itin[:sd].strftime('%d/%m/%Y')
      end

      click_on 'fdimgbutton'

      # Empty result...
      Capybara.default_wait_time = SHORT_WAIT
      return if has_selector? '.noresults'
      Capybara.default_wait_time = LONG_WAIT

      # Wait for progress bar...
      if has_selector? '#progressDiv'

        # Now wait for it to disappear...
        if has_no_selector? '#progressDiv'

          prices << { itin: itin, price: find('.bookitprice').text.gsub(/\D/,'').to_i }
          prices.sort_by! { |p| p[:price] }
          save_screenshot "#{itin.values.join('_')}.png"
          puts prices.first
          return
        end

      end

    end

    def run_query(oa, od, da, dd, sd)

      # Get codes for all airports
      oa.each { |a| get_code a }
      da.each { |a| get_code a }

      # Here's the massive loop...
      # for all origin airports on all origin dates
      # and all destination airports on all destination dates
      # check all strikes on all strike dates
      oa.each do |_oa|
        od.each do |_od|
          da.each do |_da|
            dd.each do |_dd|

              # Get a baseline by testing without the strike
              # test_strike oa: _oa, od: _od, da: _da, dd: _dd

              sd.each do |_sd|
                strikes.each do |s|
                  test_strike oa: _oa, od: _od, da: _da, dd: _dd, sd: _sd, ssrc: s[:src], sdst: s[:dst]
                end
              end
            end
          end
        end
      end


    end
  end
end

opts = Trollop::options do
  opt :oa, "Origin Airport(s)", type: :string
  opt :od, "Origin Date(s)", type: :string
  opt :da, "Destination Airport(s)", type: :string
  opt :dd, "Destination Date(s)", type: :string
  opt :sd, "Strike Date(s)", type: :string
end

def parse_dates(dates)
  dates.split(',').map { |d| Date.parse d }
end

oa = opts[:oa].split(',')
od = parse_dates opts[:od]
da = opts[:da].split(',')
dd = parse_dates opts[:dd]
sd = parse_dates opts[:sd]

# Set a longer web timeout?
http = Net::HTTP.new(@host, @port)
http.read_timeout = 60

t = Kayak::Query.new
#t.run_search
t.run_query oa, od, da, dd, sd