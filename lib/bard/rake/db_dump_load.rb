require "backhoe"

namespace :db do
  desc "Dump the current database to db/data.sql"
  task :dump => :environment do
    Backhoe.dump
  end

  desc "Load the db/data.sql data into the current database."
  task :load => ["db/data.sql", "db:drop:current", "db:create:current"] do
    Backhoe.load
  end
end

# FIXME is this necessary? Why can't we just rely on RAILS_ENV?
if defined?(ActiveRecord)
  namespace :db do
    namespace :create do
      task :current => :load_config do
        if ActiveRecord::Tasks::DatabaseTasks.respond_to?(:current_config)
          config = ActiveRecord::Tasks::DatabaseTasks.current_config
          ActiveRecord::Tasks::DatabaseTasks.create config
        else
          ActiveRecord::Tasks::DatabaseTasks.create_current Rails.env
        end
      end
    end

    namespace :drop do
      task :current => :load_config do
        if ActiveRecord::Tasks::DatabaseTasks.respond_to?(:current_config)
          config = ActiveRecord::Tasks::DatabaseTasks.current_config
          ActiveRecord::Tasks::DatabaseTasks.drop config
        else
          ActiveRecord::Tasks::DatabaseTasks.drop_current Rails.env
        end
      end
    end
  end
end

