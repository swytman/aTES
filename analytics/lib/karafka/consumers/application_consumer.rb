require_relative '../db/connection'

class ApplicationConsumer < Karafka::BaseConsumer
  def consume
    messages.each do |message|
      puts message.payload
    end
  end

  def db
    @db ||= Db::Connection.new.connection
  end
end