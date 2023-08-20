require_relative 'base_handler'
class ApiFinishDayHandler < BaseHandler
  include Producer
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def call
    produce_day_finished_event

    success_response(result: true)
  end

  private

  def produce_day_finished_event
    event = {
      event_name: 'DayFinished',
      data: {finished_at: Time.now.strftime("%Y-%m-%dT%H:%M:%S%z")}
    }
    # result = SchemaRegistry.validate_event(event, 'ates.day_finished', version: 1)
    # raise 'SchemaValidationFailed' if result.failure?

    producer.produce_sync(payload: event.to_json, topic: 'accounting-commands')
  end
end