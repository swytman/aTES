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
        ApiUsersHandler.new.call
      end

      r.get 'tasks' do
        user = Auth.new(r).call
        unless user
          response.status = 403
          return
        end

        ApiTasksHandler.new(user).call
      end

      r.post 'tasks' do
        user = Auth.new(r).call
        unless user
          response.status = 403
          return
        end

        body = (JSON.parse(r.body.read))

        ApiNewTaskHandler.new(user, body).call
      end

      r.on 'tasks' do
        r.post 'reassign' do
          user = Auth.new(r).call
          unless user
            response.status = 403
            return
          end

          ApiReassignTaskHandler.new(user).call
        end

        r.post Integer, 'resolve' do |task_id|
          user = Auth.new(r).call
          unless user
            response.status = 403
            return
          end

          ApiResolveTaskHandler.new(user, task_id).call
        end
      end
    end
  end
end