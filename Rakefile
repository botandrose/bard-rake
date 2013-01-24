require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "bard-rake"
    gem.summary = %Q{Rake tasks for all bard projects.}
    gem.description = %Q{Rake tasks for all bard projects.
* Bootstrap projects
* Database backup}
    gem.email = "micah@botandrose.com"
    gem.homepage = "http://github.com/botandrose/bard-rake"
    gem.authors = ["Micah Geisel"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

task :release do
  system "git push"
end
