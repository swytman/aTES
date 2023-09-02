require_relative '../transaction_repo.rb'
require_relative '../producer'

module Handlers
  class DayFinishedHandler
    include Producer
    attr_accessor :data

    def initialize(data)
      @data = data
    end

    def call
      pay_all
    end

    private

    def prepared_data(uuid)
      {
        finished_at: data['finished_at'],
        user_uuid: uuid
      }
    end

    def pay_all
      db[:users].each do |user|
        transaction_data, cleaning_uuids = TransactionRepo.new(prepared_data(user[:uuid])).payment_transaction
        produce_transaction_created_event(transaction_data) if transaction_data
        produce_transaction_finished_events(cleaning_uuids)
      end
    end

    def produce_transaction_finished_events(cleaning_uuids)
      messages = []
      cleaning_uuids.each do |tr_uuid|
        event = {
          event_name: 'TransactionFinished',
          data: {uuid: tr_uuid, finished_at: data['finished_at']}
        }
        # result = SchemaRegistry.validate_event(event, 'ates.transaction_updated', version: 1)
        # raise 'SchemaValidationFailed' if result.failure?

        messages << {
          topic: 'transactions-lifecycle',
          payload: event.to_json
        }
      end

      producer.produce_many_sync(messages) if messages.any?
    end

    def produce_transaction_created_event(transaction_data)
      event = {
        event_name: 'TransactionCreated',
        data: transaction_data
      }
      # result = SchemaRegistry.validate_event(event, 'ates.transaction_updated', version: 1)
      # raise 'SchemaValidationFailed' if result.failure?

      producer.produce_sync(payload: event.to_json, topic: 'transactions-lifecycle')
    end

    def db
      @db ||= Db::Connection.new.connection
    end
  end
end