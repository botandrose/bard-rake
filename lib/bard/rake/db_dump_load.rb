namespace :db do
  namespace :drop do
    task :current_environment => [:load_config, :rails_env] do
      drop_database_and_rescue Rails.env
    end
  end

  desc "Dump the current database to db/data.sql"
  task :dump => :environment do
    klass = adapter_from_config BardRake.database_config
    klass.dump
  end

  desc "Load the db/data.sql data into the current database."
  task :load => ["db:drop:current_environment", "db:create"] do
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

  class Sqlite3
    class << self
      include Rake::DSL

      def dump
        FileUtils.cp database, FILE_PATH
      end

      def load
        FileUtils.cp FILE_PATH, database
      end

      private

      def database
        BardRake.database_config["database"]
      end
    end
  end

  class Postgresql
    class << self
      include Rake::DSL

      def dump
        pg_dump = `which pg_dump`.strip
        raise RuntimeError, "Cannot find pg_dump." if pg_dump.blank?
        sh "#{pg_dump} -f#{FILE_PATH} #{database}"
      end

      def load
        psql = `which psql`.strip
        raise RuntimeError, "Cannot find psql." if psql.blank?
        sh "#{psql} -q -d#{database} -f#{FILE_PATH}"
      end

      private

      def database
        BardRake.database_config["database"]
      end
    end
  end

  class Mysql
    class << self
      include Rake::DSL

      def dump
        mysqldump = `which mysqldump`.strip
        raise RuntimeError, "Cannot find mysqldump." if mysqldump.blank?
        sh "#{mysqldump} --add-drop-database --databases -e #{mysql_options} > #{FILE_PATH}"
      end

      def load
        mysql = `which mysql`.strip
        raise RuntimeError, "Cannot find mysql." if mysql.blank?
        sh "#{mysql} #{mysql_options} < #{FILE_PATH}"
      end

      private
      
      def mysql_options
        config = BardRake.database_config
        options =  " -u #{config["username"]}"
        options += " -p'#{config["password"]}'" if config["password"]
        options += " -h #{config["host"]}"      if config["host"]
        options += " -S #{config["socket"]}"    if config["socket"]
        options += " '#{config["database"]}'"
      end
    end
  end

  Mysql2 = Mysql
end