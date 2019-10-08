class Match < ApplicationRecord
  has_many :user_match_states
  has_many :users, through: :user_match_states

  def self.client_codes

    url = 'https://api.namara.io/v0/data_sets/7352032b-b304-44a4-8c8f-c530f1ea1813/data/en-0?geometry_format=wkt&api_key=89843c662df3cfa55288578854faf74c4e2908d8da7c3bf0cf0d8d5f05ef7256&organization_id=5b51fc635796961117434bf0&project_id=5d49c2c1634365000f4d9e31'
    request = HTTParty.get(url)
    response = JSON.parse(request.body)
    codes = response.map {|x| x.values[2]}

  end

  def self.matched_codes

    arr = Listing.take(Listing.count)
    arr_OH = []

    arr.each do |a|
      arr_OH.push(a.code)
    end

    return arr_OH & client_codes

  end

  def self.update_matches_db

    matched_codes.each do |c|
      if Match.where(:code => c).blank?
        Match.create(address: NamaraNiqlStatementBuilder.address(c),
                     code: c,
                     dd_key: NamaraNiqlStatementBuilder.key(c),
                     matched_on: DateTime.now, week_matched: DateTime.now.cweek, year_matched: Date.today.year)
      end
    end

  end

  def self.year_organized(year = 2019, start_week = 1)
    last_week = 52
    weeks = start_week..last_week
    week = weeks.to_a

    arr = []
    week.each do |w|

      days_week = Date.commercial(year, w).all_week(:sunday).to_a
      # days_week.unshift(days_week[0] - 1)
      # days_week.pop
      # days_week.reverse
      temp = []

      days_week.each do |d|
        temp.push({"date" => d, "addresses" => [], "key" => "#{year}-#{w}"})


      end

      arr.push(temp)


    end

    return arr

  end

end
