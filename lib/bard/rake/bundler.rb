# clear out rails 2.3's gems tasks if bundler is used for the current project
def bundler_used?
  File.exist? "Gemfile"
end

def is_rails_2?
  Rake::Task.tasks.include?(:gems)
end

if bundler_used? and is_rails_2?
  Rake::Task[:gems].clear
  Rake::Task[:"gems:install"].clear
end
