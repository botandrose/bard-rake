require "rails/generators"

module Bard
  class Utf8mb4MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path("templates", __dir__)

    def self.next_migration_number(dirname)
      next_migration_number = current_migration_number(dirname) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end

    def install_migration
      migration_template "migration.rb", "db/migrate/convert_to_utf8mb4.rb"
    end

    def specify_charset_and_collation_in_database_yml
      ["config/database.yml", "config/database.sample.yml"].each do |file|
        ["  collation: utf8mb4_general_ci\n", "  charset: utf8mb4\n"].each do |line|
          inject_into_file file, line, after: "  socket: /var/run/mysqld/mysqld.sock\n"
        end
      end
    end
  end
end

