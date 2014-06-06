require 'trollop'
require './pososhok_query.rb'
require './pososhok_query2.rb'

opts = Trollop::options do
  opt :src, 'Source airport', type: :string, required: true
  opt :dst, 'Destination airport', type: :string, required: true
  opt :date, 'Date', type: :string, default: Date.today.to_s
  opt :airline, 'Airline', type: :string
  opt :writeresponse, 'Write response to file', type: :boolean, default: false
end

# Convert date string to actual date
opts[:date] = Date.parse(opts[:date])

prices = PososhokQuery2.new.run(opts)
puts prices