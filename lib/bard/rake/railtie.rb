module Bard
  module Rake
    class Railtie < Rails::Engine
      rake_tasks do
        load "bard/rake.rb"
      end 
    end
  end
end
