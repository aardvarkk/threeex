require 'capybara'
require 'capybara-webkit'
require 'capybara-user_agent'
require 'open-uri'

Capybara.current_driver = :webkit
Capybara.default_wait_time = 5
# Capybara::UserAgent.add_user_agents googlebot: 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'

module Kayak
  class Query
    include Capybara::DSL
    include Capybara::UserAgent::DSL
    
    def run_query

      # set_user_agent :googlebot
      # target = 'http://www.ca.kayak.com'
      # target = 'http://www.ca.kayak.com/flights'
      # target = 'http://www.ca.kayak.com/flights?mc=y'
      # visit target

      # Fill in the form
      # fill_in 'origin0', with: 'YYZ'
      # fill_in 'destination0', with: 'ARN'
      # fill_in 'depart_date0', with: '04/08/2014'
      # fill_in 'origin1', with: 'ARN'
      # fill_in 'destination1', with: 'YYZ'
      # fill_in 'depart_date1', with: '18/08/2014'
      # fill_in 'origin2', with: 'KIR'
      # fill_in 'destination2', with: 'DUB'
      # fill_in 'depart_date2', with: '25/08/2014'
      # click_on 'fdimgbutton'

      # print page.html

      # save_screenshot 'screenshot.png'

      # response_headers.each { |h| puts h }
      # driver.cookies.each { |c| puts c }
      # driver.browser.get_cookies.each { |c| puts c }

      target = 'http://www.ca.kayak.com/flights/YYZ-ARN/2014-08-04/ARN-YYZ/2014-08-18/KIR-DUB/2014-08-25'
      visit target
      save_screenshot 'screenshot.png'

      # Capybara.current_session.driver.request.cookies.[]('auth_token').should_not be_nil
      # auth_token_value = Capybara.current_session.driver.request.cookies.[]('auth_token')
      # Capybara.reset_sessions!
      # driver.browser.set_cookie("auth_token=#{auth_token_value}")

      # If it's reCAPTCHA, grab the image
      if has_selector? '#recaptcha_challenge_image', wait: 5
        reCAPTCHA = find '#recaptcha_challenge_image'

        open('reCAPTCHA.jpg', 'wb') do |file|
          file << open(reCAPTCHA['src']).read
        end

        puts 'reCAPTCHA'
        return
      end

      find '#progressDiv'
      find '.pagecontrols'
      all('.bookitprice').each do |p|
        puts p.text
      end
    end
  end
end

t = Kayak::Query.new
t.run_query

