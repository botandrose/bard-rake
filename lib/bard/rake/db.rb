namespace :db do
  desc "Dump the current database to db/data.sql"
  task :dump => :environment do
    klass = adapter_from_config BardRake.database_config
    klass.dump
  end

  desc "Load the db/data.sql data into the current database."
  task :load => ["db:drop", "db:create"] do
    klass = adapter_from_config BardRake.database_config
    klass.load
  end

  def adapter_from_config config
    "BardRake::#{config["adapter"].camelize}".constantize
  end
end

module BardRake
  FILE_PATH = "db/data.sql"

  def self.database_config
    @config ||= ActiveRecord::Base.configurations[Rails.env || "development"]
  end

  class Postgresql
    def self.dump
      pg_dump = `which pg_dump`.strip
      raise RuntimeError, "Cannot find pg_dump." if pg_dump.blank?
      sh "#{pg_dump} -f#{FILE_PATH} #{database}"
    end

    def self.load
      psql = `which psql`.strip
      raise RuntimeError, "Cannot find psql." if psql.blank?
      sh "#{psql} -q -d#{database} -f#{FILE_PATH}"
    end

    private

    def self.database
      BardRake.database_config["database"]
    end
  end

  class Mysql
    def self.dump
      mysqldump = `which mysqldump`.strip
      raise RuntimeError, "Cannot find mysqldump." if mysqldump.blank?
      sh "#{mysqldump} -e #{mysql_options} > #{FILE_PATH}"
    end

    def self.load
      mysql = `which mysql`.strip
      raise RuntimeError, "Cannot find mysql." if mysql.blank?
      sh "#{mysql} #{mysql_options} < #{FILE_PATH}"
    end

    private
    
    def self.mysql_options
      config = BardRake.database_config
      options =  " -u #{config["username"]}"
      options += " -p'#{config["password"]}'" if config["password"]
      options += " -h #{config["host"]}"      if config["host"]
      options += " -S #{config["socket"]}"    if config["socket"]
      options += " '#{config["database"]}'"
    end
  end

  Mysql2 = Mysql
end
