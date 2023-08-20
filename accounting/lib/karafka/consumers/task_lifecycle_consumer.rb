require_relative 'application_consumer'

class TaskLifecycleConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      message = message.payload
      case message['event_name']
      when'TaskAssigned'
        Handlers::TaskAssignedHandler.new(task_assigned_data(message)).call
      when 'TaskReassigned'
        Handlers::TaskAssignedHandler.new(task_assigned_data(message)).call
      when 'TaskResolved'
        Handlers::TaskResolvedHandler.new(task_resolved_data(message)).call
      end
      puts message
    end
  rescue StandardError => e
    MyLogger.info e.message
    raise 'NoTask' if e.message == 'NoTask'
  end

  private

  def task_assigned_data(message)
    message['data'].slice('task_uuid', 'assignee_uuid')
  end

  def task_resolved_data(message)
    message['data'].slice('task_uuid', 'resolver_uuid')
  end
end