task :restart do
  system "touch tmp/restart.txt"
end

desc "Bootstrap project"
task :bootstrap => "bootstrap:files" do
  invoke_task_if_exists "db:create"
  invoke_task_if_exists "db:migrate:all"
  Rake::Task["restart"].invoke
end

namespace :bootstrap do
  desc "Bootstrap project to run in production"
  task :production => "bootstrap:files" do
    invoke_task_if_exists "db:create"
    invoke_task_if_exists "db:migrate"

    invoke_task_if_exists "assets:precompile"
    invoke_task_if_exists "bootstrap:production:post"
    Rake::Task["restart"].invoke
  end

  namespace :production do
    task :post do
    end
  end

  task :files do
    system "cp config/database.sample.yml config/database.yml" unless File.exist?('config/database.yml') or !File.exist?('config/database.sample.yml')
  end
end
