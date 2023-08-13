Db::Migration.new(File.basename(__FILE__)).call do
  connection = Db::Connection.new.connection
  connection.drop_table? :users if ENV['INIT'] == '1'
  connection.drop_table? :tasks if ENV['INIT'] == '1'

  connection.create_table? :users do
    primary_key :id
    UUID :uuid
    String :user
    String :role
  end

  connection.create_table? :tasks do
    primary_key :id
    UUID :user_uuid
    Text :description
    DateTime :created_at
    DateTime :closed_at
    Integer :assign_price
    Integer :resolve_price
    String :status
  end
end

