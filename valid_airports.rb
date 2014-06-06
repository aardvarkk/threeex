require 'date'
require 'pry'
require './pososhok_query.rb'
require './pososhok_query2.rb'

SRC = "YTO"

def get_filename(src)
  return "valid_#{src}"
end

# Get all airports
f = File.read('openflights/openflights/data/airports.dat')
airports = f.scan(/"([A-Z0-9]{3})\"/).map { |a| a.first }
# p airports

# Remove all known-valid from the list so we don't retry them
known_valid = []
File.readlines(get_filename(SRC)).each { |l| known_valid << l.strip } if File.exists? get_filename(SRC)
puts "Found #{known_valid.length} known valid airports"
# p known_valid

# Optional: Ignore everything from airports up to the index of the last known-valid airport
puts "Ignoring airports up to index #{airports.index(known_valid.last)}"
airports = airports[airports.index(known_valid.last)..-1] if !airports.index(known_valid.last).nil?

# Subtract known-valid airports
(airports - known_valid).each_with_index do |a,i|

  opts = {
    src: SRC,
    dst: a,
    date: Date.today
  }
  puts "Querying #{opts}"
  

  prices = PososhokQuery2.new.run(opts)

  # Check that search was correct
  if !prices.empty?
  
    if opts[:src] != prices.first[:src]
      puts "IGNORING: Requested source #{opts[:src]} doesn't match returned source #{prices.first[:src]}"
    elsif opts[:dst] != prices.first[:dst]
      puts "IGNORING: Requested destination #{opts[:dst]} doesn't match returned destination #{prices.first[:dst]}"
    else
      puts prices
      f = File.open(get_filename(opts[:src]), 'a')
      f.puts a
      f.close
    end
  end

  puts "Sleeping after airport #{i+1} of #{airports.length}..."
  sleep(Random.rand(3...5))

end
