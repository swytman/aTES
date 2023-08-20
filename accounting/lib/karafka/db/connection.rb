require "sequel"

module Db
  class Connection
    def initialize
      @@db ||= new_connection
    end

    def connection
      @@db
    end

    def create_migrations_table
      return if @@db.table_exists?(:migrations)

      @@db.create_table :migrations do
        primary_key :id
        String :key
      end
    end

    def migrate
      path = File.join(File.dirname(__FILE__), 'migrations')
      Dir.entries(path).each do|file|
        next unless File.file?(File.join(path, file))
        require_relative "migrations/#{file}"
      end
    end

    def self.execute(sql)
      @@db.execute sql
    end

    private

    def new_connection
      Sequel.connect(
        adapter: :postgres,
        database: 'accounting',
        user: 'postgres',
        password: 'postgres',
        host: 'db',
        port: 5432,
        max_connections: 10,
        logger: Logger.new('log/db.logs')
      )
    end
  end
end