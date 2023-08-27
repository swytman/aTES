module Producer
  def producer
    @producer ||= WaterDrop::Producer.new do |config|
      config.kafka = {
        'bootstrap.servers': ENV['KAFKA_BOOTSTRAP'],
        'sasl.mechanism': 'SCRAM-SHA-256',
        'sasl.username': ENV['KAFKA_USER'],
        'sasl.password': ENV['KAFKA_PASSWORD'],
        'security.protocol': 'sasl_ssl'
      }
    end
  end
end