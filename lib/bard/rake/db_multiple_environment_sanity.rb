if defined?(ActiveRecord)
  namespace :db do
    namespace :create do
      task :all => [:load_config] do
        invoke_task_if_exists :rails_env
        run_in_all_environments do |config|
          ActiveRecord::Base.establish_connection(config)
          ActiveRecord::Tasks::DatabaseTasks.create config
        end

        if includes_test_environment? && !parallel?
          invoke_task_if_exists "parallel:create"
        end
      end
    end

    namespace :drop do
      task :all => [:load_config] do
        invoke_task_if_exists :rails_env
        run_in_all_environments do |config|
          ActiveRecord::Base.establish_connection(config)
          ActiveRecord::Tasks::DatabaseTasks.drop config
        end

        if includes_test_environment? && !parallel?
          invoke_task_if_exists "parallel:drop"
        end
      end
    end

    namespace :migrate do
      task :all => [:load_config] do
        invoke_task_if_exists :rails_env
        run_in_all_environments do |config|
          ActiveRecord::Base.establish_connection(config)
          ActiveRecord::Tasks::DatabaseTasks.migrate
        end

        if includes_test_environment? && !parallel?
          invoke_task_if_exists "parallel:migrate"
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

    def includes_test_environment?
      %w(development test).include?(rails_env)
    end

    def rails_env
      if defined?(Rails)
        Rails.env
      else
        ENV["RAILS_ENV"]
      end
    end

    def parallel?
      !!ENV["TEST_ENV_NUMBER"]
    end
  end
end

