require 'digest'
require 'jwt'
require_relative 'handler_response'

class ApiLoginHandler
  include Producer
  attr_accessor :body

  def initialize(body)
    @body = body
  end

  def call
    return HandlerResponse.new(400, 'User not found!') unless user

    HandlerResponse.new(200, token)
  end

  private

  def user
    @user ||= users.where(username: body['user'], password: hashed_password).first
  end

  def db
    @db ||= Db::Connection.new.connection
  end

  def users
    db[:users]
  end

  def token
    pp ENV['TOKEN_KEY']
    @token ||= generate_token
  end

  def generate_token
    payload = user.slice(:uuid).merge(expires_at: Time.now.to_i + 60 * 60 * 24 * 30)
    secret_key = ENV['TOKEN_KEY']
    algorithm = 'HS256'

    {
      payload:,
      token: JWT.encode(payload, secret_key, algorithm)
    }
  end

  def hashed_password
    Digest::SHA256.hexdigest(body['password'])
  end
end