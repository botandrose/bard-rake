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
