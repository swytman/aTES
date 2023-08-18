Db::Migration.new(File.basename(__FILE__)).call do
  connection = Db::Connection.new.connection
  connection.drop_table? :users if ENV['INIT'] == '1'

  connection.create_table? :users do
    primary_key :id
    UUID :uuid
    String :username
    String :password
    String :role
  end
end

