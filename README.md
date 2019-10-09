# Dye & Durham Leads
This app uses machine learning technologies developed by ThinkData Works to provide clients with the addresses of homes on the market that are also recorded on said client's database. The app can be found at: https://dye-durham-leads.herokuapp.com/.

## Prerequisites

-   [PostgreSQL](https://www.postgresql.org) database

## Installing

1.  Clone the repository:

    ```
    git clone https://github.com/tristan-sharma/dye-durham-leads.git
    ```
   
2. Setup the database:

    ```
    bin/rake db:setup
    ```
    
## Development

Run the development server with default configuration on http://localhost:3000:

    bin/rails s
    
### Rake Tasks and Cronjobs

Cronjobs are run every 24h using the `whenever` gem to retrieve the addresses of real estate listings from the Namara data-feeds and to check for address matches on the client dataset.

Bring the latest home addresses on the market from Namara into the `Listings` table:

    
    rake update_listings
    

Add the addresses of homes that are on both the client dataset and on the market to the `Matches` table:

    
    rake update_matches
    
   
