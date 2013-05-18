# ensure spec task is defined if rspec is in the project
begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError; end

task :set_test_env do
  ENV["RAILS_ENV"] = "test"
  RAILS_ENV = "test"
end

task :bootstrap_test => [:set_test_env, :bootstrap]

task :parallel => ["parallel:create", "parallel:prepare", "parallel:features"]

Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
desc "Bootstrap the current project and run the tests."
task :default => [:bootstrap_test] do
  invoke_task_if_exists "spec"
  require "debugger"; debugger
  if ENV["CI"] && Rake::Task.task_defined?("parallel:features")
    Rake::Task[:parallel].invoke
  else
    invoke_task_if_exists "cucumber"
  end
  invoke_task_if_exists "spec:javascripts"
end

task :ci => [:set_ci_env, :set_fail_fast_env, :bootstrap_test, "assets:clean:all", "assets:precompile", :default]

task :set_ci_env do
  ENV["CI"] = "1"
end

task :set_fail_fast_env do
  ENV["FAIL_FAST"] = "1"
end
