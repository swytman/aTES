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
        ApiUsersHandler.new.call
      end

      # POST /api/register
      r.post 'register' do
        ApiRegisterHandler.new(JSON.parse(r.body.read)).call
      end

      # POST /api/login
      r.post 'login' do
        ApiLoginHandler.new(JSON.parse(r.body.read)).call
      end
    end
  end
end