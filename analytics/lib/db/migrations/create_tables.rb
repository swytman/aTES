Db::Migration.new(File.basename(__FILE__)).call do
  connection = Db::Connection.new.connection
  connection.drop_table? :users if ENV['INIT'] == '1'
  connection.drop_table? :tasks if ENV['INIT'] == '1'
  connection.drop_table? :transactions if ENV['INIT'] == '1'

  connection.create_table? :users do
    primary_key :id
    UUID :uuid
    String :username
    String :role
    Integer :balance, default: 0
  end

  connection.create_table? :tasks do
    primary_key :id
    UUID :uuid
    UUID :user_uuid
    String :title
    Text :description
    DateTime :created_at
    DateTime :closed_at
    Integer :assign_price
    Integer :resolve_price
    String :status
  end

  connection.create_table? :transactions do
    primary_key :id
    UUID :uuid
    Integer :credit
    Integer :debit
    UUID :user_uuid
    String :type
    String :desc
    DateTime :created_at
    DateTime :finished_at
  end
end

