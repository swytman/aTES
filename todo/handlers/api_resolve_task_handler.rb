class ApiResolveTaskHandler
  include Producer
  attr_accessor :user, :task_id

  def initialize(user, task_id)
    @user = user
    @task_id = task_id
  end

  def call
    return 'NoTaskFound' unless task
    return 'TaskAlreadyResolved' if task[:status] == 'closed'
    return 'NoAccess' unless access?

    resolve_task
  end

  private

  def resolve_task
    resolved = {closed_at: Time.now, status: 'closed'}
    db[:tasks].where(id: task_id).update(resolved)
    updated_task = task.merge(resolved)
    produce_task_resolved_event(updated_task)

    updated_task
  end

  def produce_task_resolved_event(updated_task)
    event = {
      event_name: 'TaskResolved',
      data: updated_task
    }

    producer.produce_sync(payload: event.to_json, topic: 'tasks-stream')
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