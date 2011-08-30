namespace :db do
  desc "Dump the current database to db/data.sql"
  task :dump => :environment do
    mysqldump = `which mysqldump`.strip
    raise RuntimeError, "Cannot find mysqldump." if mysqldump.blank?
    sh "#{mysqldump} -e #{mysql_options} > #{file_path}"
  end

  desc "Load the db/data.sql data into the current database."
  task :load => ["db:drop", "db:create"] do
    mysql = `which mysql`.strip
    raise RuntimeError, "Cannot find mysql." if mysql.blank?
    sh "#{mysql} #{mysql_options} < #{file_path}"
  end

  def file_path
    "db/data.sql"
  end

  def mysql_options
    config = ActiveRecord::Base.configurations[Rails.env || "development"]
    raise RuntimeError, "I only work with mysql." unless config["adapter"].starts_with? "mysql"

    options =  " -u #{config["username"]}"
    options += " -p'#{config["password"]}'" if config["password"]
    options += " -h #{config["host"]}"      if config["host"]
    options += " -S #{config["socket"]}"    if config["socket"]
    options += " '#{config["database"]}'"
  end
end
