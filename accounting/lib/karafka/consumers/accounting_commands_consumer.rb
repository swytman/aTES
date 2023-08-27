require_relative 'application_consumer'

class AccountingCommandsConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      message = message.payload
      case message['event_name']
      when'DayFinished'
        Handlers::DayFinishedHandler.new(day_finished_data(message)).call
      end
      puts message
    end
  rescue StandardError => e
    puts e.message
  end

  private

  def day_finished_data(message)
    message['data'].slice('finished_at')
  end
end