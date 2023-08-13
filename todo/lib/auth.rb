require_relative 'db/connection'
require 'jwt'

class Auth
  attr_accessor :request

  def initialize(request)
    @request = request
  end

  def call
    return unless token

    user
  rescue JWT::VerificationError
    false
  end

  private

  def headers
    request.env.select { |k,v| k.start_with? 'HTTP_'}.
      transform_keys { |k| k.sub(/^HTTP_/, '').split('_').map(&:capitalize).join('-') }
  end

  def user
    db[:users].where(uuid: decoded_payload['uuid']).first || false
  end

  def db
    @db ||= Db::Connection.new.connection
  end

  def token
    headers['Authorization']
  end

  def decoded_payload
    @decoded_token ||= JWT.decode(token, ENV['TOKEN_KEY'], true, algorithm: 'HS256')[0]
  end
end