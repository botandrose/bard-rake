task :restart do
  system "touch tmp/restart.txt"
  system "if which passenger-config >/dev/null; then passenger-config restart-app `pwd`; fi"
end

desc "Bootstrap project"
task :bootstrap do
  system "cp config/database.sample.yml config/database.yml" unless File.exist?('config/database.yml') or !File.exist?('config/database.sample.yml')
  case ENV["RAILS_ENV"]
  when "production", "staging"
    invoke "db:prepare"
    invoke_task_if_exists "assets:precompile"
  when "test"
    invoke parallel? ? "parallel:prepare" : "db:prepare"
    invoke_task_if_exists "assets:precompile"
  else # development
    invoke "db:prepare"
    invoke_task_if_exists "parallel:prepare"
  end
  invoke "restart"
end

def parallel?
  Rake::Task.task_defined?("parallel:create")
end

