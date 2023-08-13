require 'digest'
require 'securerandom'

class ApiRegisterHandler
  include Producer
  attr_accessor :body

  def initialize(body)
    @body = body
  end

  def call
    return 'User exists!' if user_exists?

    create_db_user
    produce_user_created_event

    user_data
  end

  private

  def produce_user_created_event
    event = {
      event_name: 'UserCreated',
      data: user_data.slice(:user, :uuid, :role)
    }

    producer.produce_sync(payload: event.to_json, topic: 'users-stream')
  end

  def db
    @db ||= Db::Connection.new.connection
  end

  def user_exists?
    users.where(user: body['user']).count.positive?
  end

  def create_db_user
    users.insert(user_data)
  end

  def users
    db[:users]
  end

  def user_data
    @user_data ||= {
      user: body['user'],
      password: hashed_password,
      uuid: generate_uuid,
      role: body['role'] || roles_list.sample
    }
  end

  def roles_list
    %w[user admin manager accountant]
  end

  def hashed_password
    Digest::SHA256.hexdigest(body['password'])
  end

  def generate_uuid
    SecureRandom.uuid
  end

  def generate_secret
    Digest::SHA256.hexdigest(SecureRandom.uuid)
  end
end