task :restart do
  system "touch tmp/restart.txt"
  system "touch tmp/debug.txt" if ENV["DEBUG"] == 'true'
end

desc "Bootstrap project"
task :bootstrap => "bootstrap:files" do
  invoke_task_if_exists "db:create"
  Rake::Task["db:migrate:all"].invoke if Rake::Task.task_defined?("db:migrate")
  Rake::Task["restart"].invoke
end

namespace :db do
  namespace :migrate do
    task :all => [:load_config, :rails_env] do
      configs_for_environment.each do |config|
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
    task :all => [:load_config, :rails_env] do
      configs_for_environment.each do |config|
        ActiveRecord::Base.establish_connection(config)
        step = ENV['STEP'] ? ENV['STEP'].to_i : 1
        ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
      end

      Rake::Task["db:_dump"].invoke
    end
  end
end

namespace :bootstrap do
  desc "Bootstrap project to run in production"
  task :production => "bootstrap:files" do
    invoke_task_if_exists "db:create"
    invoke_task_if_exists "db:migrate"

    if %w(app/stylesheets app/sass public/stylesheets/sass).any? { |file| File.exist?(file) }
      Sass::Plugin.options[:always_update] = true;
      Sass::Plugin.update_stylesheets
    end
    invoke_task_if_exists "barista:brew"
    invoke_task_if_exists "asset:packager:build_all"
    invoke_task_if_exists "assets:precompile"
    invoke_task_if_exists "bootstrap:production:post"
    Rake::Task["restart"].invoke
  end

  namespace :production do
    task :post do
    end
  end

  task :files do
    system "git submodule sync"
    system "git submodule init"
    system "git submodule update --merge"
    system "git submodule foreach 'git checkout `git name-rev --name-only HEAD`'"
    system "cp config/database.sample.yml config/database.yml" unless File.exist?('config/database.yml') or !File.exist?('config/database.sample.yml')
  end
end

Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
desc "Bootstrap the current project and run the tests."
task :default => [:set_test_env, :bootstrap, :spec] do
  invoke_task_if_exists "cucumber"
  invoke_task_if_exists "spec:javascripts"
end

task :ci => [:set_fail_fast, "assets:clean:all", "assets:precompile", :default]

task :set_fail_fast do
  ENV["FAIL_FAST"] = "1"
end

task :set_test_env do
  ENV["RAILS_ENV"] = "test"
  RAILS_ENV = "test"
end

def invoke_task_if_exists task_name
  Rake::Task[task_name].invoke if Rake::Task.task_defined? task_name
end
