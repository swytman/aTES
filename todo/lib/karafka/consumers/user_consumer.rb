require_relative 'application_consumer'

class UserConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      message = message.payload
      case message['event_name']
      when'UserCreated'
        users.insert(user_data(message))
      end
      puts message
    end
  rescue StandardError => e
    puts e.message
  end

  private

  def user_data(message)
    message['data'].slice('user', 'uuid', 'role')
  end

  def users
    db[:users]
  end
end