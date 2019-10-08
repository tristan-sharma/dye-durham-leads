task update_matches: :environment do
  Match.update_matches_db
end
