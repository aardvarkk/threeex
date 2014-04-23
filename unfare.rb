require 'rest_client'
require 'trollop'
require './pososhok_parser.rb'

opts = Trollop::options do
  opt :src, 'Source airport', type: :string, required: true
  opt :date, 'Date', type: :string, required: true
  opt :dst, 'Destination airport', type: :string, required: true
  opt :airline, 'Airline', type: :string
end

# NOTE: MUST USE METRO CODES, NOT AIRPORTS (IAH -> HOU)

params = nil
cookies = nil
cookie_str = nil
sss = nil

RestClient.get 'www.pososhok.ru/partner/english' do |response, request, result|
  cookies = response.cookies
  cookie_str = cookies.map { |k,v| "#{k}=#{v}"}.join('; ')
  sss = response.to_s.scan(/sss.+value="(.+)"/)[0][0]
  # puts sss
end

# Format is DD/MM/YYYY
params = {
  'FlightSearchForm.routeType' => 'ROUND_TRIP',
  'FlightSearchForm.date.0' => Date.parse(opts[:date]).strftime('%d.%m.%Y'),
  'FlightSearchForm.date.1' => Date.parse(opts[:date]).strftime('%d.%m.%Y'),
  'FlightSearchForm.departureLocation.0' => opts[:src],
  'FlightSearchForm.departureLocation.0.CODE' => opts[:src],
  'FlightSearchForm.arrivalLocation.0' => opts[:dst],
  'FlightSearchForm.arrivalLocation.0.CODE' => opts[:dst],
  'FlightSearchForm.adultsType' => 'ADULT',
  'FlightSearchForm.adultsCount' => '1',
  'FlightSearchForm.children' => '0',
  'FlightSearchForm.infants' => '0',
  'FlightSearchForm.searchType' => 'TARIFFS',
  'FlightSearchForm.anyAirline' => 'true',
  'validateForm' => 'true',
  'sss' => sss
}

if opts[:airline]
  params['FlightSearchForm.airline'] = opts[:airline]
  params['FlightSearchForm.anyAirline'] = 'false'
end

RestClient.post 'www.pososhok.ru/partner/english', params, { cookies: cookies } do |response, request, result|
  # p request.headers
  # p response.code
  # p response.headers
  # p response.cookies
  # p response.to_s
end

RestClient.get 'www.pososhok.ru/partner/english/avia/step2_tariffs.html?action=select_tariff', cookie: cookie_str do |response, request, result|
  # p request.headers
  # p response.code
  # p response.headers
  # p response.cookies
  # p response.to_s
  # File.open('response.html', 'w') { |file| file.write response }
end

params = {
  'cmd' => 'get_search_results',
  'search_type' => 'TARIFFS',
  'do_search' => 'true'
}

RestClient.post 'www.pososhok.ru/system/modules/com.gridnine.opencms.modules.pososhok/pages/ajax_provider_avia.jsp', params, { cookies: cookies } do |response, request, result|
  # p request.headers
  # p response.code
  # p response.headers
  # p response.cookies
  # p response.to_s
end

RestClient.get 'www.pososhok.ru/partner/english/avia/step2_tariffs.html?action=select_tariff', cookie: cookie_str do |response, request, result|
  # p request.headers
  # p response.code
  # p response.headers
  # p response.cookies
  # p response.to_s
  # File.open('response.html', 'w') { |file| file.write response }
  puts PososhokParser::parse(response.to_s)
end

