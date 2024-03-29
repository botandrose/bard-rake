# ensure spec task is defined if rspec is in the project
begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end unless Rake::Task.task_defined?(:spec)

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
  invoke_task_if_exists "spec:javascripts"

  if ENV["CI"] && Rake::Task.task_defined?("parallel:features")
    Rake::Task["parallel"].invoke
  else
    invoke_task_if_exists "cucumber"
  end
end

task :ci => [:set_ci_env, :bootstrap_test, "log:clear", "assets:clean", "assets:precompile", :default, :clean]

task :set_ci_env do
  ENV["CI"] = "1"
end

task :clean do
  if ENV["CLEAN"]
    FileUtils.rm_rf "public/assets"
  end
end
