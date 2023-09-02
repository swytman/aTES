require 'roda'
require_relative 'lib/auth'

class App < Roda
  plugin :json

  route do |r|
    # GET /
    r.root do
      'Welcome to PopungInc ANALITICS service'
    end

    r.on 'api' do
      r.get 'users' do
        result = ApiUsersHandler.new.call
        response.status = result.code

        result.body
      end

      r.get 'tasks' do
        result = ApiTasksHandler.new.call
        response.status = result.code

        result.body
      end

      r.get 'transactions' do
        result = ApiTransactionsHandler.new.call
        response.status = result.code

        result.body
      end
    end

  end
end