namespace :db do
  desc "Dump the current database to db/data.sql"
  task :dump => :environment do
    config = ActiveRecord::Base.configurations[RAILS_ENV || 'development']
    filepath  = "db/data.sql"
    mysqldump = `which mysqldump`.strip
    options   =  "-e -u #{config['username']}"
    options   += " -p'#{config['password']}'" if config['password']
    options   += " -h #{config['host']}"      if config['host']
    options   += " -S #{config['socket']}"    if config['socket']

    raise RuntimeError, "I only work with mysql." unless config['adapter'].starts_with? 'mysql'
    raise RuntimeError, "Cannot find mysqldump." if mysqldump.blank?
    
    `#{mysqldump} #{options} #{config['database']} > #{filepath}`
  end

  desc "Load the db/data.sql data into the current database."
  task :load => :environment do
    config = ActiveRecord::Base.configurations[RAILS_ENV || 'development']
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    mysql = `which mysql`.strip
    options  = " -u#{config['username']}"
    options += " -p#{config['password']}" if config['password']
    options += " -h #{config['host']}"    if config['host']

    raise RuntimeError, "I only work with mysql." unless config['adapter'].include? 'mysql'
    raise RuntimeError, "Cannot find mysql." if mysql.blank?

    sh "#{mysql} #{options} '#{config["database"]}' < db/data.sql"
  end
end
