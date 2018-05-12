require "backhoe"

namespace :db do
  desc "Dump the current database to db/data.sql"
  task :dump => :environment do
    Backhoe.dump
  end

  desc "Load the db/data.sql data into the current database."
  task :load => ["db:drop:current", "db:create:current"] do
    Backhoe.load
  end
end

