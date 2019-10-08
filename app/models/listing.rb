class Listing < ApplicationRecord

  def self.address_code(address_array)

  auth_header = "Basic YWRtaW46dGVzdGluZ2tleQ=="
  url = "http://localhost:8080/entities/update?columns=address"

  vals = []

  address_array.each do |a|
    vals.push({columns:[{column: "address", value: a}]})
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

  return entities
end

def self.pull_openhouse

  # offset = 0
  # while true
    url = "https://api.namara.io/v0/data_sets/63225d5d-07e9-488e-89f9-1f4bc2249125/data/en-0?geometry_format=wkt&api_key=89843c662df3cfa55288578854faf74c4e2908d8da7c3bf0cf0d8d5f05ef7256&organization_id=5b51fc635796961117434bf0&project_id=5d49c2c1634365000f4d9e31"
    # &limit=250&offset=#{offset}"
    request = HTTParty.get(url)
    response = JSON.parse(request.body)

    records = []

    response.each do |i|
      records.push({"address" => i["address"], "formatted_address" => i["formatted_address"], "retrieved_at" => i["retrieved_at"]})
    end

  #   offset += 250
  #   break if records.length.zero?
  # end

  return records

end


def self.assign_codes

  arr = []
  pull_openhouse.each do |r|

    arr.push(r["formatted_address"])

  end

  code_hashes = address_code(arr)
  updated_record = pull_openhouse

  updated_record.each do |a|

    code_key = code_hashes.find { |c| c["columns"][0]["original_value"] == a["formatted_address"]}
    a["code"] = code_key["code"]

  end

  return updated_record


end

def self.update_listings_db

  assign_codes.each do |c|
    if Listing.where(:code => c["code"]).blank?
      Listing.create(address: c["address"], formatted_address: c["formatted_address"], retrieved_at: c["retrieved_at"], code: c["code"], added_on: DateTime.now)
    end

  end

end


end
