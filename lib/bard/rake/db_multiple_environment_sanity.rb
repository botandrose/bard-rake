if defined?(ActiveRecord)
  namespace :db do
    namespace :create do
      task :all => :load_config do
        invoke_with_parallel "create"
      end
    end

    namespace :drop do
      task :all => :load_config do
        invoke_with_parallel "drop"
      end
    end

    namespace :migrate do
      task :all => :load_config do
        invoke_with_parallel "migrate"
      end
    end

    namespace :rollback do
      task :all => :load_config do
        invoke_with_parallel "rollback" do # 6.1, 7.0 vanilla doesn't follow the pattern of the other three
          ActiveRecord::Base.connection.migration_context.rollback(1)
        end
      end
    end

    def invoke_with_parallel task
      if Rails.version >= "7.1"
        Rake::Task["db:#{task}"].invoke
        if %w[development test].include?(Rails.env) && Rake::Task.task_defined?("parallel:#{task}")
          Rake::Task["parallel:#{task}"].invoke
        end

      else # Rails 6.1, 7.0
        run_in_all_environments do |config, env|
          if env == "test" && Rake::Task.task_defined?("parallel:#{task}")
            Rake::Task["parallel:#{task}"].invoke
          else
            if block_given?
              yield
            else
              ActiveRecord::Tasks::DatabaseTasks.send task.to_sym, config
            end
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
        if Rails.version < "7"
          configuration = db_config.config
          database = configuration["database"]
        else
          configuration = db_config.configuration_hash
          database = configuration[:database]
        end

        next unless database
        next unless whitelist.include?(env)
        next if modified_databases.include?(database)

        ActiveRecord::Base.establish_connection configuration
        block.call configuration, env

        modified_databases << database
      end

      Rake::Task["db:_dump"].invoke
    end
  end
end

