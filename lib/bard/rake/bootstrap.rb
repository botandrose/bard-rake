task :restart do
  system "touch tmp/restart.txt"
  system "touch tmp/debug.txt" if ENV["DEBUG"] == 'true'
end

desc "Bootstrap project"
task :bootstrap => %w(bootstrap:files db:create db:migrate restart)

namespace :bootstrap do
  desc "Bootstrap project to run in production"
  task :production => :bootstrap do
    if %w(app/stylesheets app/sass public/stylesheets/sass).any? { |file| File.exist?(file) }
      Sass::Plugin.options[:always_update] = true;
      Sass::Plugin.update_stylesheets
    end
    Rake::Task["barista:brew"].invoke if Rake::Task.task_defined?("barista:brew")
    Rake::Task["asset:packager:build_all"].invoke if File.exist?("vendor/plugins/asset_packager")
    Rake::Task["bootstrap:production:post"].invoke if Rake::Task.task_defined?("bootstrap:production:post")
    Rake::Task["restart"].execute
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
    system "cp config/database.sample.yml config/database.yml" unless File.exist?('config/database.yml')
  end
end

Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
desc "Bootstrap the current project and run the tests."
task :default => do
  system "rake bootstrap spec cucumber RAILS_ENV=test"
end
