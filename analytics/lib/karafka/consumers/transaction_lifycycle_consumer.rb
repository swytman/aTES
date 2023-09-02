require_relative 'application_consumer'

class TransactionLifecycleConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      message = message.payload
      case message['event_name']
      when 'TransactionCreated'
        handle_transaction_created(message)
      when 'TransactionFinished'
        handle_transaction_finished(message)
      end
      puts message
    end
  rescue StandardError => e
    MyLogger.info e.message
    raise 'NoTask' if e.message == 'NoTask'
  end

  private

  def handle_transaction_created(message)
    data = message['data'].slice(
      "uuid",
      "credit",
      "debit",
      "type",
      "desc",
      "user_uuid",
      "created_at",
      "finished_at"
    )
    db[:transactions].insert(data)
  end

  def handle_transaction_finished(message)
    data = message['data'].slice('uuid', 'finished_at')
    db[:transactions].where(uuid: data['uuid']).update(
      finished_at: data['finished_at']
    )
  end
end