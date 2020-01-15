if defined?(ActiveRecord)
  namespace :db do
    namespace :create do
      task :all => :load_config do
        run_in_all_environments do |config, env|
          if env == "test" && Rake::Task.task_defined?("parallel:create")
            Rake::Task["parallel:create"].invoke
          else
            ActiveRecord::Tasks::DatabaseTasks.create config
          end
        end
      end
    end

    namespace :drop do
      task :all => :load_config do
        run_in_all_environments do |config, env|
          if env == "test" && Rake::Task.task_defined?("parallel:drop")
            Rake::Task["parallel:drop"].invoke
          else
            ActiveRecord::Tasks::DatabaseTasks.drop config
          end
        end
      end
    end

    namespace :migrate do
      task :all => :load_config do
        run_in_all_environments do |config, env|
          if env == "test" && Rake::Task.task_defined?("parallel:migrate")
            Rake::Task["parallel:migrate"].invoke
          else
            ActiveRecord::Tasks::DatabaseTasks.migrate
          end
        end
      end
    end

    namespace :rollback do
      task :all => :load_config do
        run_in_all_environments do |config, env|
          if env == "test" && Rake::Task.task_defined?("parallel:rollback")
            Rake::Task["parallel:rollback"].invoke
          else
            ActiveRecord::Base.connection.migration_context.rollback(1)
          end
        end
      end
    end

    def run_in_all_environments &block
      invoke_task_if_exists :rails_env

      whitelist = %w(development test staging production)
      modified_databases = Set.new

      ActiveRecord::Base.configurations.configs_for.each do |db_config|
        env = db_config.env_name
        configuration = db_config.config
        database = configuration["database"]

        next unless database
        next unless whitelist.include?(env)
        next if modified_databases.include?(database)

        if local_database?(configuration)
          ActiveRecord::Base.establish_connection configuration
          block.call configuration, env
        else
          $stderr.puts "This task only modifies local databases. #{database} is on a remote host."
        end

        modified_databases << database
      end

      Rake::Task["db:_dump"].invoke
    end

    def local_database?(configuration)
      configuration["host"].blank? || ActiveRecord::Tasks::DatabaseTasks::LOCAL_HOSTS.include?(configuration["host"])
    end

    def test_environment?
      rails_env == "test"
    end

    def rails_env
      if defined?(Rails)
        Rails.env
      else
        ENV["RAILS_ENV"]
      end
    end
  end
end

