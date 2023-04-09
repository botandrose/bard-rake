require "backhoe"

namespace :db do
  desc "Dump the current database to db/data.sql.gz"
  task :dump => :environment do
    Backhoe.dump "db/data.sql.gz"
  end

  desc "Load the db/data.sql data into the current database."
  task :load => :environment do
    Backhoe.load "db/data.sql.gz", drop_and_create: true
  end

  task :backup => :environment do
    project_name = File.basename(Dir.getwd)
    Backhoe.backup "bard-backup/#{project_name}", **Rails.application.credentials.bard_backup
  end

  task "drop:current" => :environment do
    ActiveRecord::Tasks::DatabaseTasks.drop Rails.env.to_sym
  end

  task "create:current" => :environment do
    ActiveRecord::Tasks::DatabaseTasks.create Rails.env.to_sym
  end
end

