require 'nokogiri'
require 'open-uri'

class WelcomeController < ApplicationController

  URL = 'http://www.ca.kayak.com/flights/YYZ-ARN/2014-08-04/ARN-YYZ/2014-08-18/KIR-DUB/2014-08-25'
  USER_AGENT = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0'

  def index
    @doc = Nokogiri::HTML(open(URL, 'User-Agent' => USER_AGENT))
    render :text => @doc, :layout => false
  end
end
