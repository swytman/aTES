require_relative 'handler_response'
require 'schema_registry'

class BaseHandler

  private

  def success_response(data)
    HandlerResponse.new(200, data)
  end

  def no_access_error
    HandlerResponse.new(403, message: 'NoAccess')
  end
end