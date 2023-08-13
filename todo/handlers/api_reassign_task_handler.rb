class ApiReassignTaskHandler
  include Producer
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def call
    return 'NoAccess' unless access?

    messages = []
    tasks.each do |task|
      new_uuid = staff_users.sample[:uuid]
      db[:tasks].where(id: task[:id]).update(user_uuid: new_uuid)

      messages << {
        topic: 'tasks-stream',
        payload: {
          event_name: 'TaskReassigned',
          data: task.merge!(user_uuid: new_uuid)
        }.to_json
      }
    end
    producer.produce_many_sync(messages)
  end

  private

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