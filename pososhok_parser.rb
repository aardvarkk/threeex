require 'pry'
require 'nokogiri'

class PososhokParser

  def self.parse(response)
    results = []

    doc = Nokogiri::HTML(response)
    nodes = doc.xpath('//div[@id="search-results"]')
    # p nodes

    # Prices
    prices = nodes.xpath('//td[@class="price"]//text()')
    # puts prices

    # Fare basis codes and airlines
    fare_basis = nodes.xpath('//td//comment()')
    # puts fare_basis

    # Verify route
    route = nodes.xpath('//td[@class="destination"]/text()').first
    return results if route.nil?
    src = route.text.scan(/\((.{3})\)/)[0][0].strip
    dst = route.text.scan(/\((.{3})\)/)[1][0].strip

    prices.zip(fare_basis).each_with_index do |v,i|
      results << { 
        price: v[0].text.scan(/\d+/)[0].to_i, 
        fare_basis: v[1].text.scan(/fare_basis: (.+);/)[0][0],
        src: src,
        dst: dst,

        # Don't use symbols because symbols can't start with numbers (9W, for instance)
        airline: v[1].text.scan(/airline: (.+)/)[0][0].strip
      }
    end

    # Eliminate duplicates based on fare basis code + airline combo
    results = results.uniq

    return results
  end

end

# f = File.open('response.html')
# puts PososhokParser::parse(f)