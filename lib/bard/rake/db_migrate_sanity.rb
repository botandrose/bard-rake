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
  end
end
