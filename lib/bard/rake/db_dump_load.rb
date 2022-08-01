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

  task "drop:current" => :environment do
    ActiveRecord::Tasks::DatabaseTasks.drop Rails.env.to_sym
  end

  task "create:current" => :environment do
    ActiveRecord::Tasks::DatabaseTasks.create Rails.env.to_sym
  end
end

