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

  task :backup => "bard:backup"

  task "drop:current" => :environment do
    ActiveRecord::Tasks::DatabaseTasks.drop Rails.env.to_sym
  end

  task "create:current" => :environment do
    ActiveRecord::Tasks::DatabaseTasks.create Rails.env.to_sym
  end
end
