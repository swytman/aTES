require 'db/connection'
require_relative 'logger_init'

sleep 0.5
db = Db::Connection.new
db.create_migrations_table
db.migrate