# require 'launchy'
# require 'net/http'
require 'rest_client'
require 'trollop'

PATH_PREFIX = 'openflights/openflights/data/'

opts = Trollop::options do
  opt :src, 'Source airport', type: :string
  opt :dst, 'Destination airport', type: :string
  opt :airline, 'Airline', type: :string
  opt :map, 'Draw map'
  opt :mapfile, 'Map filename', type: :string, default: 'map'
  opt :groupsize, 'Map group size', default: 500
end

routes = File.open(PATH_PREFIX + 'routes.dat', 'rb').read

matches = routes.scan /(#{opts[:airline].nil? ? '[\\w]{2}' : opts[:airline]}),[\d]+,(#{opts[:src].nil? ? '[\\w]{3}' : opts[:src]}),[\d]+,(#{opts[:dst].nil? ? '[\\w]{3}' : opts[:dst]})/
matches.each { |m| puts "#{m[0]}-#{m[1]}-#{m[2]}"}

# Split up into groups
index = 0
matches.each_slice opts[:groupsize] do |match_group|

  # Create a map string from the matches
  map_str = []
  match_group.each { |m| map_str << "#{m[1]}-#{m[2]}" }
  map_str = map_str.join ','

  # open('map_str', 'w') { |file| file.write map_str }

  # Label all points
  # &PM=*
  if opts[:map]
    RestClient.get "www.gcmap.com/map?P=#{map_str}&MS=wls2" do |response, request, result|
        # p response
        # p request
        # p result
        open("#{opts[:mapfile]}_#{index}.gif", 'wb') do |file|
            file.write response.body
        end
    end
  end

  index += 1

end