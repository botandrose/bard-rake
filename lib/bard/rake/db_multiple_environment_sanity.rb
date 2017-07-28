if defined?(ActiveRecord)
  namespace :db do
    def production?
      ENV["RAILS_ENV"] == "production"
    end

    def parallel?
      !!ENV["TEST_ENV_NUMBER"]
    end

    task :create do
      unless production? or parallel?
        invoke_task_if_exists "parallel:create"
      end
    end

    task :migrate do
      unless production? or parallel?
        invoke_task_if_exists "parallel:migrate"
      end
    end

    task :rollback do
      unless production? or parallel?
        invoke_task_if_exists "parallel:rollback"
      end
    end
  end
end
