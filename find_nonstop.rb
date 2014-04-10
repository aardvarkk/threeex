# require 'launchy'
# require 'net/http'
require 'rest_client'
require 'trollop'

PATH_PREFIX = 'openflights/openflights/data/'

opts = Trollop::options do
  opt :src, 'Source airport', type: :string
  opt :dst, 'Destination airport', type: :string
  opt :airline, 'Airline', type: :string
end

routes = File.open(PATH_PREFIX + 'routes.dat', 'rb').read

matches = routes.scan /(#{opts[:airline].nil? ? '[\\w]{2}' : opts[:airline]}),[\d]+,(#{opts[:src]}),[\d]+,(#{opts[:dst].nil? ? '[\\w]{3}' : opts[:dst]})/
matches.each { |m| puts "#{m[0]}-#{m[1]}-#{m[2]}"}

# Create a map string from the matches
map_str = []
matches.each { |m| map_str << "#{m[1]}-#{m[2]}" }
map_str = map_str.join ','

# Label all points
# &PM=*
RestClient.get "www.gcmap.com/map?P=#{map_str}&MS=wls2" do |response, request, result|
    # p response
    # p request
    # p result
    open('map.gif', 'wb') do |file|
        file.write response.body
    end
end