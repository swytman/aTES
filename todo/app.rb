require 'roda'
require_relative 'lib/auth'

class App < Roda
  plugin :json

  route do |r|
    # GET /
    r.root do
      'Welcome to PopungInc TODO service'
    end

    r.on 'api' do
      # GET /api/users
      r.get 'users' do
        result = ApiUsersHandler.new.call
        response.status = result.code

        result.body
      end

      r.get 'tasks' do
        user = Auth.new(r).call
        unless user
          response.status = 401
          return
        end

        result = ApiTasksHandler.new(user).call
        response.status = result.code

        result.body
      end

      r.post 'tasks' do
        user = Auth.new(r).call
        unless user
          response.status = 401
          return
        end

        body = (JSON.parse(r.body.read))

        result = ApiNewTaskHandler.new(user, body).call
        response.status = result.code

        result.body
      end

      r.on 'tasks' do
        r.post 'reassign' do
          user = Auth.new(r).call
          unless user
            response.status = 401
            return
          end

          result = ApiReassignTaskHandler.new(user).call
          response.status = result.code

          result.body
        end

        r.post Integer, 'resolve' do |task_id|
          user = Auth.new(r).call
          unless user
            response.status = 401
            return
          end
          result = ApiResolveTaskHandler.new(user, task_id).call
          response.status = result.code

          result.body
        end
      end
    end
  end
end