require_relative '../transaction_repo.rb'
require_relative '../producer'

module Handlers
  class TaskResolvedHandler
    include Producer
    attr_accessor :data

    def initialize(data)
      @data = data
    end

    def call
      transaction_data = repo.deposit_transaction
      return unless transaction_data

      produce_transaction_created_event(transaction_data)
    end

    private

    def produce_transaction_created_event(transaction_data)
      event = {
        event_name: 'TransactionCreated',
        data: transaction_data
      }
      # result = SchemaRegistry.validate_event(event, 'ates.transaction_created', version: 1)
      # raise 'SchemaValidationFailed' if result.failure?

      producer.produce_sync(payload: event.to_json, topic: 'transactions-lifecycle')
    end

    def prepared_data
      {
        user_uuid: data['resolver_uuid'],
        task_uuid: data['task_uuid']
      }
    end

    def repo
      TransactionRepo.new(prepared_data)
    end
  end
end