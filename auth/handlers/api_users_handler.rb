require_relative 'handler_response'
class ApiUsersHandler
  def call
    db = Db::Connection.new.connection
    HandlerResponse.new(200, db[:users].all)
  end
end