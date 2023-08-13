class ApiTasksHandler
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def call
    db = Db::Connection.new.connection
    return 'NoAccess' unless access?

    policy.scoped(db[:tasks]).to_a
  end

  private

  def policy
    @policy ||= Policies::TaskPolicy.new(user)
  end

  def access?
    policy.access?('tasks_list')
  end
end