task :restart do
  system "touch tmp/restart.txt"
  system "passenger-config restart-app `pwd` >/dev/null 2>&1"
end

desc "Bootstrap project"
task :bootstrap do
  invoke_take_if_exists "bootstrap:database.yml"
  invoke_task_if_exists "db:create"
  invoke_task_if_exists "db:migrate"
  invoke_task_if_exists "rake parallel:create"
  invoke_task_if_exists "rake parallel:migrate"
  if %w(staging production).include?(ENV["RAILS_ENV"])
    invoke_task_if_exists "assets:precompile"
  end
  Rake::Task["restart"].invoke
end

task "bootstrap:database.yml" do
  unless File.exist?("config/database.yml")
    %w[config/database.sample.yml config/database.yml.example].each do |path|
      if File.exist?(path)
        system "cp #{path} config/database.yml"
        break
      end
    end
  end
end
