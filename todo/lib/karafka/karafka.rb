# Define what topics you want to consume with which consumers in karafka.rb
require_relative 'consumers/user_consumer'
require_relative 'db/connection'

$stdout.sync = true

class KarafkaApp < Karafka::App
  setup do |config|
    config.client_id = 'todo_karafka'

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
end


