# require 'launchy'
# require 'net/http'
require 'rest_client'
require 'trollop'

PATH_PREFIX = 'openflights/openflights/data/'
UNSUPPORTED = %w(ULK XSB)

ALLIANCES =
{
  '*A' => %w(JP A3 AC CA NZ NH OZ OS AV SN CM OU MS ET BR LO LH SK ZH SQ SA LX TP TG TK UA),
  'OW' => %w(AB AA BA CX AY IB JL LA JJ MH QF QR RJ S7),
  'ST' => %w(SU AR AM UX AF AZ CI MU CZ OK DL KQ KL KE ME SV RO VN MF)
}

opts = Trollop::options do
  opt :src, 'Source airport', type: :string
  opt :dst, 'Destination airport', type: :string
  opt :excludeairlines, 'Excluded airlines', type: :strings
  opt :airline, 'Airline', type: :string
  opt :alliance, 'Alliance (*A, OW, ST)', type: :string
  opt :map, 'Draw map'
  opt :mapfile, 'Map filename', type: :string, default: 'map'
  opt :groupsize, 'Map group size', default: 500
  opt :label, 'Label points', type: :boolean, default: false
end

routes = File.open(PATH_PREFIX + 'routes.dat', 'rb').read

matches = routes.scan /(#{opts[:airline].nil? ? '[\\w]{2}' : opts[:airline]}),[\d]+,(#{opts[:src].nil? ? '[\\w]{3}' : opts[:src]}),[\d]+,(#{opts[:dst].nil? ? '[\\w]{3}' : opts[:dst]})/
matches.reject! { |m| opts[:alliance] && !ALLIANCES[opts[:alliance]].include?(m[0]) }
matches.reject! { |m| opts[:excludeairlines] && opts[:excludeairlines].include?(m[0])}
matches.each { |m| puts "#{m[0]}-#{m[1]}-#{m[2]}"}

# Split up into groups
index = 0
matches.each_slice opts[:groupsize] do |match_group|

  # Create a map string from the matches
  map_str = []

  # Ignore unsupported destinations
  match_group.each do |m| 
    next if UNSUPPORTED.include? m[1]
    next if UNSUPPORTED.include? m[2]
    map_str << "#{m[1]}-#{m[2]}"
  end

  map_str = map_str.join ','

  # open('map_str', 'w') { |file| file.write map_str }

  # Label all points
  # &PM=*
  # Various map styles
  # Rectangular: &MP=r
  if opts[:map]
    url = "www.gcmap.com/map?P=#{map_str}&MS=wls2&MP=r"
    url += "&PM=*" if opts[:label]
    RestClient.get url do |response, request, result|
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