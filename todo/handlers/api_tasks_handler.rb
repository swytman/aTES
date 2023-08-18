require_relative 'base_handler'
class ApiTasksHandler < BaseHandler
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def call
    db = Db::Connection.new.connection
    return no_access_error unless access?

    success_response(policy.scoped(db[:tasks]).to_a)
  end

  private

  def policy
    @policy ||= Policies::TaskPolicy.new(user)
  end

  def access?
    policy.access?('tasks_list')
  end
end