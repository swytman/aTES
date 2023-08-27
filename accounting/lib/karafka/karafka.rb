require_relative 'consumers/user_consumer'
require_relative 'consumers/task_consumer'
require_relative 'consumers/task_lifecycle_consumer'
require_relative 'consumers/accounting_commands_consumer'
require_relative 'db/connection'

$stdout.sync = true

class KarafkaApp < Karafka::App
  setup do |config|
    config.client_id = 'accounting_karafka'

    config.kafka = {
      'bootstrap.servers': ENV['KAFKA_BOOTSTRAP'],
      'sasl.mechanism': 'SCRAM-SHA-256',
      'sasl.username': ENV['KAFKA_USER'],
      'sasl.password': ENV['KAFKA_PASSWORD'],
      'security.protocol': 'sasl_ssl'
    }
  end

end

KarafkaApp.routes.draw do
  topic 'users-stream' do
    consumer UserConsumer
  end
  topic 'tasks-stream' do
    consumer TaskConsumer
  end
  topic 'tasks-lifecycle' do
    consumer TaskLifecycleConsumer

    dead_letter_queue(
      topic: 'task-lifecycle-dlq',
      max_retries: 0
    )
  end
  topic 'task-lifecycle-dlq' do
    consumer TaskLifecycleConsumer
  end
  topic 'accounting-commands' do
    consumer AccountingCommandsConsumer
  end
end


