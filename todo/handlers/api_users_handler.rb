require_relative 'base_handler'
class ApiUsersHandler < BaseHandler
  def call
    db = Db::Connection.new.connection
    success_response(db[:users].all)
  end
end