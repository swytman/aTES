require 'roda'

class App < Roda
  plugin :json

  route do |r|
    # GET /
    r.root do
      'Welcome to PopungInc AUTH service'
    end

    r.on 'api' do
      # GET /api/users
      r.get 'users' do
        result = ApiUsersHandler.new.call
        response.status = result.code

        result.body
      end

      # POST /api/register
      r.post 'register' do
        result = ApiRegisterHandler.new(JSON.parse(r.body.read)).call
        response.status = result.code

        result.body
      end

      # POST /api/login
      r.post 'login' do
        result = ApiLoginHandler.new(JSON.parse(r.body.read)).call
        response.status = result.code

        result.body
      end
    end
  end
end