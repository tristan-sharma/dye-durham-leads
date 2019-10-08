task update_matches: :environment do
  Listing.update_listings_db
end
