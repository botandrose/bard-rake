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

# FIXME is this necessary? Why can't we just rely on RAILS_ENV?
if defined?(ActiveRecord)
  namespace :db do
    namespace :create do
      task :current => :load_config do
        config = ActiveRecord::Tasks::DatabaseTasks.current_config
        ActiveRecord::Tasks::DatabaseTasks.create config
      end
    end

    namespace :drop do
      task :current => :load_config do
        config = ActiveRecord::Tasks::DatabaseTasks.current_config
        ActiveRecord::Tasks::DatabaseTasks.drop config
      end
    end
  end
end

