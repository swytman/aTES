require_relative 'base_handler'
class ApiReassignTaskHandler < BaseHandler
  include Producer
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def call
    return no_access_error unless access?

    reassign_tasks

    success_response(result: true)
  end

  private

  def reassign_tasks
    messages = []
    tasks.each do |task|
      new_user_uuid = staff_users.sample[:uuid]
      db[:tasks].where(id: task[:id]).update(user_uuid: new_user_uuid)

      event = {
        event_name: 'TaskReassigned',
        data: {task_uuid: task[:uuid], assignee_uuid: new_user_uuid}
      }
      result = SchemaRegistry.validate_event(event, 'ates.task_reassigned', version: 1)
      raise 'SchemaValidationFailed' if result.failure?

      messages << {
        topic: 'tasks-lifecycle',
        payload: event.to_json
      }
    end

    producer.produce_many_sync(messages)
  end

  def policy
    @policy ||= Policies::TaskPolicy.new(user)
  end

  def access?
    policy.access?('reassign_tasks')
  end

  def db
    @db ||= Db::Connection.new.connection
  end

  def tasks
    db[:tasks].where(status: 'new').order(:id)
  end

  def staff_users
    @staff_users ||= db[:users].exclude(role: %w[admin manager]).to_a
  end
end