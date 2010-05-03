# replace rails 2.3's gems tasks with bundler-aware versions
if File.exist? "Gemfile"
  Rake::Task[:gems].clear
  desc "Asks bundler for the status of the gem dependencies."
  task :gems do
    system "bundle show"
  end

  Rake::Task[:"gems:install"].clear
  namespace :gems do
    desc "Invoke bundle install if the dependencies aren't satisfied."
    task :install do
      system "bundle install" unless system "bundle check"
    end
  end
end
