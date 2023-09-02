require_relative 'application_consumer'

class TaskLifecycleConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      message = message.payload
      case message['event_name']
      when 'TaskReassigned'
        handle_task_reassigned(message)
      when 'TaskResolved'
        handle_task_resolved(message)
      end
      puts message
    end
  rescue StandardError => e
    MyLogger.info e.message
    raise 'NoTask' if e.message == 'NoTask'
  end

  private

  def handle_task_reassigned(message)
    data = message['data'].slice('task_uuid', 'assignee_uuid')
    db[:tasks].where(uuid: data['task_uuid']).update(user_uuid: data['assignee_uuid'])
  end

  def handle_task_resolved(message)
    data = message['data'].slice('task_uuid', 'resolver_uuid', 'closed_at')
    db[:tasks].where(uuid: data['task_uuid']).update(
      user_uuid: data['resolver_uuid'],
      closed_at: data['closed_at']
    )
  end
end