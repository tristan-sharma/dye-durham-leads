set :output, "log/cron.log"

every 3.hours do
  # specify the task name as a string
  rake "update_matches", :environment => "development"
end
