require_relative 'base_handler'
class ApiResolveTaskHandler < BaseHandler
  include Producer
  attr_accessor :user, :task_id

  def initialize(user, task_id)
    @user = user
    @task_id = task_id
  end

  def call
    return no_task_found_error unless task
    return task_already_resolved_error if task[:status] == 'closed'
    return no_access_error unless access?

    success_response(resolve_task)
  end

  private

  def no_task_found_error
    HandlerResponse.new(404, message: 'NoTaskFound')
  end

  def task_already_resolved_error
    HandlerResponse.new(400, message: 'TaskAlreadyResolved')
  end

  def resolve_task
    db[:tasks].where(id: task_id).update(closed_at: Time.now, status: 'closed')
    produce_task_resolved_event

    {result: true}
  end

  def produce_task_resolved_event
    event = {
      event_name: 'TaskResolved',
      data: {task_uuid: task[:uuid], resolver_uuid: user[:uuid]}
    }
    result = SchemaRegistry.validate_event(event, 'ates.task_resolved', version: 1)
    raise 'SchemaValidationFailed' if result.failure?

    producer.produce_sync(payload: event.to_json, topic: 'tasks-lifecycle')
  end

  def db
    @db ||= Db::Connection.new.connection
  end

  def task
    @task ||= fetch_task
  end

  def fetch_task
    db[:tasks].where(id: task_id).first
  end

  def policy
    @policy ||= Policies::TaskPolicy.new(user, task)
  end

  def access?
    policy.access?('resolve_task')
  end
end