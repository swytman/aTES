class ApiNewTaskHandler
  include Producer
  attr_accessor :user, :body

  def initialize(user, body)
    @user = user
    @body = body
  end

  def call
    return 'NoAccess' unless access?

    db[:tasks].insert(task_data)
    produce_task_created_event

    task_data
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
      user_uuid: staff_user[:uuid],
      description: body['description'],
      status: 'new',
      created_at: Time.now,
      assign_price:,
      resolve_price:
    }
  end

  def assign_price
    rand(10..20) * (-1)
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

    producer.produce_sync(payload: event.to_json, topic: 'tasks-stream')
  end
end