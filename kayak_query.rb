require 'capybara'
require 'capybara-webkit'

Capybara.current_driver = :webkit
Capybara.default_wait_time = 30

module Kayak
  class Query
    include Capybara::DSL
    
    def run_query
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

