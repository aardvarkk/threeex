require 'trollop'
require './metro_codes.rb'
require './pososhok_query.rb'

opts = Trollop::options do
  opt :src, 'Source airport', type: :string, required: true
  opt :date, 'Date', type: :string, required: true
  opt :dst, 'Destination airport', type: :string, required: true
  opt :airline, 'Airline', type: :string
  opt :writeresponse, 'Write response to file', type: :boolean, default: false
end

# NOTE: MUST USE METRO CODES, NOT AIRPORTS (IAH -> HOU)
if AIRPORT_TO_METRO.has_key? opts[:src].to_sym
  puts "Warning: Replacing #{opts[:src]} with #{AIRPORT_TO_METRO[opts[:src].to_sym]}"
  opts[:src] = AIRPORT_TO_METRO[opts[:src].to_sym]
end

if AIRPORT_TO_METRO.has_key? opts[:dst].to_sym
  puts "Warning: Replacing #{opts[:dst]} with #{AIRPORT_TO_METRO[opts[:dst].to_sym]}"
  opts[:dst] = AIRPORT_TO_METRO[opts[:dst].to_sym]
end

PososhokQuery::run(opts)