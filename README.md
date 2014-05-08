Currently Google’s search bot has two official user agents: Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html) and the less common Googlebot/2.1 (+http://www.google.com/bot.html)

# OpenFlights.org

https://sourceforge.net/p/openflights/code/HEAD/tree/openflights/data/airports.dat?format=raw
https://sourceforge.net/p/openflights/code/HEAD/tree/openflights/data/airlines.dat?format=raw
https://sourceforge.net/p/openflights/code/HEAD/tree/openflights/data/routes.dat?format=raw

# Airports

Airport ID Unique OpenFlights identifier for this airport.
Name Name of airport. May or may not contain the City name.
City Main city served by airport. May be spelled differently from Name.
Country Country or territory where airport is located.
IATA/FAA 3-letter FAA code, for airports located in Country "United States of America".
3-letter IATA code, for all other airports.
Blank if not assigned.
ICAO  4-letter ICAO code.
Blank if not assigned.
Latitude Decimal degrees, usually to six significant digits. Negative is South, positive is North.
Longitude  Decimal degrees, usually to six significant digits. Negative is West, positive is East.
Altitude In feet.
Timezone Hours offset from UTC. Fractional hours are expressed as decimals, eg. India is 5.5.
DST Daylight savings time. One of E (Europe), A (US/Canada), S (South America), O (Australia), Z (New Zealand), N (None) or U (Unknown). See also: Help: Time

The data is ISO 8859-1 (Latin-1) encoded, with no special characters.

Note: Rules for daylight savings time change from year to year and from country to country. The current data is an approximation for 2009, built on a country level. Most airports in DST-less regions in countries that generally observe DST (eg. AL, HI in the USA, NT, QL in Australia, parts of Canada) are marked incorrectly.

# Airlines

Airline ID Unique OpenFlights identifier for this airline.
Name Name of the airline.
Alias Alias of the airline. For example, All Nippon Airways is commonly known as "ANA".
IATA 2-letter IATA code, if available.
ICAO 3-letter ICAO code, if available.
Callsign Airline callsign.
Country Country or territory where airline is incorporated.
Active "Y" if the airline is or has until recently been operational, "N" if it is defunct. This field is not reliable: in particular, major airlines that stopped flying long ago, but have not had their IATA code reassigned (eg. Ansett/AN), will incorrectly show as "Y".

The data is ISO 8859-1 (Latin-1) encoded. The special value \N is used for "NULL" to indicate that no value is available, and is understood automatically by MySQL if imported.

Notes: Airlines with null codes/callsigns/countries generally represent user-added airlines. Since the data is intended primarily for current flights, defunct IATA codes are generally not included. For example, "Sabena" is not listed with a SN IATA code, since "SN" is presently used by its successor Brussels Airlines.

# Routes

Airline 2-letter (IATA) or 3-letter (ICAO) code of the airline.
Airline ID Unique OpenFlights identifier for airline (see Airline).
Source airport 3-letter (IATA) or 4-letter (ICAO) code of the source airport.
Source airport ID Unique OpenFlights identifier for source airport (see Airport)
Destination airport 3-letter (IATA) or 4-letter (ICAO) code of the destination airport.
Destination airport ID  Unique OpenFlights identifier for destination airport (see Airport)
Codeshare "Y" if this flight is a codeshare (that is, not operated by Airline, but another carrier), empty otherwise.
Stops Number of stops on this flight ("0" for direct)
Equipment 3-letter codes for plane type(s) generally used on this flight, separated by spaces

The data is ISO 8859-1 (Latin-1) encoded. The special value \N is used for "NULL" to indicate that no value is available, and is understood automatically by MySQL if imported.

Notes:

    Routes are directional: if an airline operates services from A to B and from B to A, both A-B and B-A are listed separately.
    Routes where one carrier operates both its own and codeshare flights are listed only once. 

ruby kayak_query.rb --od 2014-04-05,2014-04-06,2014-04-07 --oa GOT --dd 2014-04-30 --da JFK --sd 2014-05-01

# Features to Add

* Show listing of "failed" airport searches to either stop checking for them or fix any issues
