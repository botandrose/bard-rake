if defined?(ActiveRecord)
  namespace :db do
    namespace :migrate do
      task :all => [:load_config] do
        invoke_task_if_exists :rails_env
        run_in_all_environments do |config|
          ActiveRecord::Base.establish_connection(config)
          ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
          ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
            ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
          end
        end

        Rake::Task["db:_dump"].invoke
      end
    end

    namespace :rollback do
      task :all => [:load_config] do
        invoke_task_if_exists :rails_env
        run_in_all_environments do |config|
          ActiveRecord::Base.establish_connection(config)
          step = ENV['STEP'] ? ENV['STEP'].to_i : 1
          ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
        end

        Rake::Task["db:_dump"].invoke
      end
    end

    def run_in_all_environments &block
      if defined?(ActiveRecord::Tasks::DatabaseTasks)
        ActiveRecord::Tasks::DatabaseTasks.send :each_local_configuration, &block
      else
        configs_for_environment.each &block
      end
    end

    namespace :drop do
      task :current => [:load_config] do
        if defined?(ActiveRecord::Tasks::DatabaseTasks)
          config = ActiveRecord::Tasks::DatabaseTasks.current_config
          ActiveRecord::Tasks::DatabaseTasks.drop config
        else
          drop_database current_config
        end
      end
    end

    namespace :create do
      task :current => [:load_config] do
        if defined?(ActiveRecord::Tasks::DatabaseTasks)
          config = ActiveRecord::Tasks::DatabaseTasks.current_config
          ActiveRecord::Tasks::DatabaseTasks.create config
        else
          create_database current_config
        end
      end
    end
  end
end
