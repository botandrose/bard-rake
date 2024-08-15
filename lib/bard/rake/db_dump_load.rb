require "backhoe"
require "bard-backup"

namespace :db do
  desc "Dump the current database to supplied path (default: db/data.sql.gz)"
  task :dump, [:path] => :environment do |_, args|
    args.with_defaults(path: "db/data.sql.gz")
    Backhoe.dump args.path
  end

  desc "Load the supplied path (default: db/data.sql.gz) into the current database."
  task :load, [:path] => :environment do |_, args|
    args.with_defaults(path: "db/data.sql.gz")
    Backhoe.load args.path, drop_and_create: true
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

