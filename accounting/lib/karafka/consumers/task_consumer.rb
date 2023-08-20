require_relative 'application_consumer'

class TaskConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      message = message.payload
      case message['event_name']
      when'TaskCreated'
        tasks.insert(user_data(message))
      end
      puts message
    end
  rescue StandardError => e
    puts e.message
  end

  private

  def user_data(message)
    message['data'].slice('uuid', 'title', 'assign_price', 'resolve_price')
  end

  def tasks
    db[:tasks]
  end
end