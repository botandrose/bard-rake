task :restart do
  system "touch tmp/restart.txt"
  system "if which passenger-config >/dev/null; then passenger-config restart-app `pwd`; fi"
end

desc "Bootstrap project"
task :bootstrap do
  system "cp config/database.sample.yml config/database.yml" unless File.exist?('config/database.yml') or !File.exist?('config/database.sample.yml')
  invoke_task_if_exists "db:create"
  invoke_task_if_exists "db:migrate"
  if ENV["RAILS_ENV"] == "production"
    invoke_task_if_exists "assets:precompile"
  end
  Rake::Task["restart"].invoke
end

