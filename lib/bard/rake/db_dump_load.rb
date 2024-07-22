require "backhoe"
require "bard-backup"

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
    config = Rails.application.credentials.bard_backup
    s3_path = config.delete(:s3_path) || "bard-backup/#{project_name}"
    Bard::Backup.call s3_path, **config
  end

  task "drop:current" => :environment do
    ActiveRecord::Tasks::DatabaseTasks.drop Rails.env.to_sym
  end

  task "create:current" => :environment do
    ActiveRecord::Tasks::DatabaseTasks.create Rails.env.to_sym
  end
end

