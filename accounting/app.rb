require 'roda'
require_relative 'lib/auth'

class App < Roda
  plugin :json

  route do |r|
    # GET /
    r.root do
      'Welcome to PopungInc ACCOUNTING service'
    end

    r.on 'api' do
      # GET /api/profile
      r.get 'profile' do
        user = Auth.new(r).call
        unless user
          response.status = 401
          return
        end

        result = ApiProfileHandler.new(user).call
        response.status = result.code

        result.body
      end

      # GET /api/stats
      r.get 'stats' do
        user = Auth.new(r).call
        unless user
          response.status = 401
          return
        end

        result = ApiStatsHandler.new(user).call
        response.status = result.code

        result.body
      end

      # POST /api/finish_day
      r.post 'finish_day' do
        user = Auth.new(r).call
        unless user
          response.status = 401
          return
        end

        result = ApiFinishDayHandler.new(user).call
        response.status = result.code

        result.body
      end

    end
  end
end