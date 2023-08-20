require_relative 'base_handler'
require 'securerandom'
class ApiNewTaskHandler < BaseHandler
  include Producer
  attr_accessor :user, :body

  def initialize(user, body)
    @user = user
    @body = body
  end

  def call
    return no_access_error unless access?

    db[:tasks].insert(task_data)
    produce_task_created_event
    produce_task_assigned_event

    success_response(task_data)
  end

  private

  def policy
    @policy ||= Policies::TaskPolicy.new(user)
  end

  def access?
    policy.access?('new_task')
  end

  def db
    @db ||= Db::Connection.new.connection
  end

  def task_data
    @task_data ||= {
      uuid: generate_uuid,
      user_uuid: staff_user[:uuid],
      description: body['description'],
      title: body['title'],
      status: 'new',
      created_at: Time.now.strftime("%Y-%m-%dT%H:%M:%S%z"),
      assign_price:,
      resolve_price:
    }
  end
  def generate_uuid
    SecureRandom.uuid
  end

  def assign_price
    rand(10..20)
  end

  def resolve_price
    rand(20..40)
  end

  def staff_user
    db[:users].exclude(role: %w[admin manager]).to_a.sample
  end

  def produce_task_created_event
    event = {
      event_name: 'TaskCreated',
      data: task_data
    }

    result = SchemaRegistry.validate_event(event, 'ates.task_created', version: 1)
    raise 'SchemaValidationFailed' if result.failure?

    producer.produce_sync(payload: event.to_json, topic: 'tasks-stream')
  end

  def produce_task_assigned_event
    event = {
      event_name: 'TaskAssigned',
      data: {task_uuid: task_data[:uuid], assignee_uuid: task_data[:user_uuid]}
    }
    result = SchemaRegistry.validate_event(event, 'ates.task_assigned', version: 1)
    raise 'SchemaValidationFailed' if result.failure?

    producer.produce_sync(payload: event.to_json, topic: 'tasks-lifecycle')
  end
end