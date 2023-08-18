module Policies
  class TaskPolicy
    attr_accessor :user, :object

    def initialize(user, object = nil)
      @user = user
      @object = object
    end

    def scoped(collection)
      (admin? || manager?) ? collection.order(:id) : collection.where(user_uuid: uuid).order(:id)
    end

    def access?(method)
      case method
      when 'tasks_list'
        true
      when 'new_task'
        true
      when 'reassign_tasks'
        admin? || manager?
      when 'resolve_task'
        uuid == object[:user_uuid]
      else
        false
      end
    end

    private

    def uuid
      user[:uuid]
    end

    def role
      user[:role]
    end

    def admin?
      role == 'admin'
    end

    def manager?
      role == 'manager'
    end
  end
end