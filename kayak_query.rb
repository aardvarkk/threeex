require 'capybara'
require 'capybara-webkit'

Capybara.current_driver = :webkit
Capybara.default_wait_time = 30
Capybara::UserAgent.add_user_agents googlebot: 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'

module Kayak
  class Query
    include Capybara::DSL
    include Capybara::UserAgent::DSL
    
    def run_query
      set_user_agent :googlebot
      target = 'http://www.ca.kayak.com/flights/YYZ-ARN/2014-08-04/ARN-YYZ/2014-08-18/KIR-DUB/2014-08-25'
      visit target
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

