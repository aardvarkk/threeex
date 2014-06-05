require 'date'
require './pososhok_query.rb'

# Get all airports
f = File.read('openflights/openflights/data/airports.dat')
airports = f.scan(/"([A-Z0-9]{3})\"/).map { |a| a.first }
# p airports

airports.each_with_index do |a,i|

  opts = {
    src: "YTO",
    dst: a,
    date: Date.today
  }
  puts "Querying #{opts}"
  
  prices = PososhokQuery::run(opts)
  if !prices.empty?
    puts prices
    f = File.open("valid_#{opts[:src]}.dat", 'a')
    f.puts a
    f.close
  end

  puts "Sleeping after airport #{i+1} of #{airports.length}..."
  sleep(Random.rand(3...5))

end
