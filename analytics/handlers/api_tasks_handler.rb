require_relative 'handler_response'
class ApiTasksHandler
  def call
    db = Db::Connection.new.connection
    HandlerResponse.new(200, db[:tasks].all)
  end
end