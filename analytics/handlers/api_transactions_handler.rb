require_relative 'handler_response'
class ApiTransactionsHandler
  def call
    db = Db::Connection.new.connection
    HandlerResponse.new(200, db[:transactions].all)
  end
end