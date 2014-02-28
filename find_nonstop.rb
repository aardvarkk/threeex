src = ARGV[0]
dst = ARGV[1]
routes = File.open('routes.dat', 'rb').read

if src && dst
  # matches = routes.scan /([\w]{2}),[\d]+,#{src},[\d]+,#{dst},[\d]+,(Y*)/
  matches = routes.scan /([\w]{2}),[\d]+,(#{src}),[\d]+,(#{dst})/
elsif src
  matches = routes.scan /([\w]{2}),[\d]+,(#{src}),[\d]+,([\w]{3})/
end

matches.each { |m| puts "#{m[0]}-#{m[1]}-#{m[2]}"}