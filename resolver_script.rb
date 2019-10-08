require 'HTTParty'
require 'json'
require 'byebug'

auth_header = "Basic YWRtaW46dGVzdGluZ2tleQ=="
url = "http://localhost:8080/entities/update?columns=address"

# Basic input, figure out how to convert dataset into this format
# vals = [{columns:[{column: "address", value:"91 Riverview Gdns"}]}, {columns:[{column: "address", value:"73 Scotch Ln"}]}, {columns:[{column: "address", value:"4 1815 denonville st montreal quebec h4e 1m4"}]}]
adds = ["Not an address-15", "15 THIRTY EIGHTH ST, Toronto, Ontario, M8W3M1", "Not an address-2", "78 WICKSON TR, Toronto, Ontario, M1B1P3", "785 Brown's Line 604, Toronto, Ontario, M8W3V8", "38 DEMARIS AVE, Toronto, Ontario, M3N1M1", "Not an address-1", "30 Rollingwood Dr, Toronto, Ontario, M2H2M5", "Not an address-14", "800 LAWRENCE AVE W 1619, Toronto, Ontario, M6A1C3", "Not an address-19", "82 CAMPANIA CRES, Toronto, Ontario, M1V2E9", "Not an address-5", "Not an address-21", "71 FRANEL CRES, Toronto, Ontario, M9L1B6", "68 Abell St, Toronto, Ontario", "125 TREVERTON RD, Toronto, Ontario, M1K3T1", "185 LEGION RD N 1906, Toronto, Ontario, M8Y0A1", "Not an address-16", "5 WHITELOCK CRES, Toronto, Ontario, M2K1V9", "Not an address-18", "142 WILLIAM DUNCAN RD, Toronto, Ontario, M3K0B5", "Not an address-4", "1990 BLOOR ST, Toronto, Ontario, M6P0B6", "15 Zorra St, Toronto, Ontario", "401 LONGMORE ST, Toronto, Ontario, M2N5C2", "Not an address-12", "35 Davies Cres, Toronto, Ontario, M4J2X7", "Not an address-20", "91 Muir Dr 1, Toronto, Ontario, M1M1S2", "478 King St W, Toronto, Ontario", "Not an address-3", "257 Blackthorn Ave, Toronto, Ontario, M6N3H7", "322 MELROSE AVE, Toronto, Ontario, M5M1Z4", "Not an address-17", "Not an address-7", "1001 Bay St, Toronto, Ontario", "20 BRUYERES MEWS N 803, Toronto, Ontario, M5V0G8", "Not an address-6", "19 ROSEBANK DR 503, Toronto, Ontario, M1B5Z2", "10 YORK ST 6705, Toronto, Ontario, M5J0E1", "10 YORK ST 6705, Toronto, Ontario, M5J0E1", "495 MELROSE AVE, Toronto, Ontario, M5M2A1", "Not an address-11", "400 ADELAIDE ST E 522, Toronto, Ontario, M5A1N4", "75 Queenswharf Rd, Toronto, Ontario", "Not an address-8", "52 FOREST MANOR RD 809, Toronto, Ontario, M2J1M6", "Not an address-10", "190 BOROUGH DR Uph3602, Toronto, Ontario, M1P0B6"]
vals = []

adds.each do |a|
vals += [{columns:[{column: "address", value: a}]}]
end



ndjson = []
vals.each do |record|
  gen = JSON.generate(record)
  ndjson.append(gen)
end

ndjson = ndjson.join("\n")

options = {
  headers: {"Authorization": auth_header, "Content-Type": "text/plain"},
  body: ndjson
}

res = HTTParty.post(url, options)

parsed = JSON.parse(res.body)
#records_str = res.body.split("\n")
records_str = parsed.split("\n")
entities = []
records_str.each do |record|
  entities.append(JSON.parse(record))
end

puts entities
