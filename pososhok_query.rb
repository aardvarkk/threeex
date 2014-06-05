require 'rest_client'
require './metro_codes.rb'
require './pososhok_parser.rb'

class PososhokQuery

  # Wrap all RestClient requests in this, so if it  fails we retry
  def self.retryable(&block)
    begin
      return yield
    rescue RestClient::Exception
      retry
    end

    yield
  end

  # opts: { date, src, dst, [airline] }
  def self.run(opts)
  
    # NOTE: MUST USE METRO CODES, NOT AIRPORTS (IAH -> HOU)
    if AIRPORT_TO_METRO.has_key? opts[:src].to_sym
      puts "Warning: Replacing #{opts[:src]} with #{AIRPORT_TO_METRO[opts[:src].to_sym]}"
      opts[:src] = AIRPORT_TO_METRO[opts[:src].to_sym]
    end

    if AIRPORT_TO_METRO.has_key? opts[:dst].to_sym
      puts "Warning: Replacing #{opts[:dst]} with #{AIRPORT_TO_METRO[opts[:dst].to_sym]}"
      opts[:dst] = AIRPORT_TO_METRO[opts[:dst].to_sym]
    end

    params = nil
    cookies = nil
    cookie_str = nil
    sss = nil

    retryable do
      RestClient.get 'www.pososhok.ru/partner/english' do |response, request, result|
        cookies = response.cookies
        cookie_str = cookies.map { |k,v| "#{k}=#{v}"}.join('; ')
        sss = response.to_s.scan(/sss.+value="(.+)"/)[0][0]
        # puts sss
      end
    end

    # Format is DD/MM/YYYY
    params = {
      'FlightSearchForm.routeType' => 'ROUND_TRIP',
      'FlightSearchForm.date.0' => opts[:date].strftime('%d.%m.%Y'),
      'FlightSearchForm.date.1' => opts[:date].strftime('%d.%m.%Y'),
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

    retryable do
      RestClient.post 'www.pososhok.ru/partner/english', params, { cookies: cookies } do |response, request, result|
        # p request.headers
        # p response.code
        # p response.headers
        # p response.cookies
        # p response.to_s
      end
    end

    retryable do
      RestClient.get 'www.pososhok.ru/partner/english/avia/step2_tariffs.html?action=select_tariff', cookie: cookie_str do |response, request, result|
        # p request.headers
        # p response.code
        # p response.headers
        # p response.cookies
        # p response.to_s
        # File.open('response.html', 'w') { |file| file.write response }
      end
    end

    params = {
      'cmd' => 'get_search_results',
      'search_type' => 'TARIFFS',
      'do_search' => 'true'
    }

    retryable do
      RestClient.post 'www.pososhok.ru/system/modules/com.gridnine.opencms.modules.pososhok/pages/ajax_provider_avia.jsp', params, { cookies: cookies } do |response, request, result|
        # p request.headers
        # p response.code
        # p response.headers
        # p response.cookies
        # p response.to_s
      end
    end

    prices = nil

    retryable do
      RestClient.get 'www.pososhok.ru/partner/english/avia/step2_tariffs.html?action=select_tariff', cookie: cookie_str do |response, request, result|
        # p request.headers
        # p response.code
        # p response.headers
        # p response.cookies
        # p response.to_s
        # File.open('response.html', 'w') { |file| file.write response } if opts[:writeresponse]
        prices = PososhokParser::parse(response.to_s)
        # puts PososhokParser::parse(response.to_s)
      end
    end

    return prices

  end

end