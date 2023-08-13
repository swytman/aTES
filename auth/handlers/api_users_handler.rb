class ApiUsersHandler
  def call
    db = Db::Connection.new.connection
    db[:users].all
  end
end