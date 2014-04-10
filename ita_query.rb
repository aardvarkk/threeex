require 'capybara'
require 'capybara-webkit'
require 'net/http' 
require 'open-uri'
require 'trollop'

LONG_WAIT = 60
SHORT_WAIT = 0

#Capybara.current_driver = :selenium
Capybara.current_driver = :webkit
# Capybara.javascript_driver = :webkit
Capybara.default_wait_time = LONG_WAIT

# Need to interact with hidden form field
Capybara.ignore_hidden_elements = false

# When searching for an airport showing up on the page, we don't care if it's ambiguous
Capybara.match = :first

# Don't need our own server, I don't think...
Capybara.run_server = false

module ITA

  PATH_PREFIX = 'openflights/openflights/data/'
  ROUTES = PATH_PREFIX + 'routes.dat'
  STRIKES = 'strikes.dat'

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

  class Query
    include Capybara::DSL

    def prices
      @prices ||= []
    end

    def codes
      @codes ||= ITA.codes
    end

    def strikes
      @strikes ||= ITA.strikes
    end

    def initialize
      ITA.load_strikes STRIKES
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
      browser = Capybara.current_session.driver.browser

      target = 'http://matrix.itasoftware.com'
      visit target

      fill_in 'advancedfrom1', with: itin[:oa]
      fill_in 'advancedto1', with: itin[:da]
      fill_in 'advanced_rtDeparture', with: itin[:od].strftime('%m/%d/%Y')
      fill_in 'advanced_rtReturn', with: itin[:dd].strftime('%m/%d/%Y')

      click_on 'advanced_searchSubmitButton'

      best_price = find '.itaBestPrice'

      prices << { itin: itin, price: best_price.text.gsub(/\D/,'').to_i }
      puts prices.last

      # save_screenshot "#{itin.values.join('_')}.png"

    end

    def run_query(oa, od, da, dd, sd)

      # Here's the massive loop...
      # for all origin airports on all origin dates
      # and all destination airports on all destination dates
      # check all strikes on all strike dates
      oa.each do |_oa|
        od.each do |_od|
          da.each do |_da|
            dd.each do |_dd|

              # Get a baseline by testing without the strike
              test_strike oa: _oa, od: _od, da: _da, dd: _dd
            end
          end
        end
      end

      prices.sort_by! { |p| p[:price] }
      puts prices

    end
  end
end

opts = Trollop::options do
  opt :oa, "Origin Airport(s)", type: :string
  opt :od, "Origin Date(s)", type: :string
  opt :da, "Destination Airport(s)", type: :string
  opt :dd, "Destination Date(s)", type: :string
end

def parse_dates(dates)
  dates.split(',').map { |d| Date.parse d }
end

oa = opts[:oa].split(',')
od = parse_dates opts[:od]
da = opts[:da].split(',')
dd = parse_dates opts[:dd]

# Set a longer web timeout?
http = Net::HTTP.new(@host, @port)
http.read_timeout = 60

t = ITA::Query.new
#t.run_search
t.run_query oa, od, da, dd, nil
