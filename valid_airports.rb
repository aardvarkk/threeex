require 'date'
require './pososhok_query.rb'

# Get all airports
f = File.read('openflights/openflights/data/airports.dat')
airports = f.scan(/"([A-Z0-9]{3})\"/).map { |a| a.first }
# p airports

airports.each do |a|
  opts = {
    src: "YYZ",
    dst: a,
    date: Date.today
  }
  puts "Querying #{opts}"
  PososhokQuery::run(opts)
end
