require_relative 'base_handler'

class ApiProfileHandler < BaseHandler
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def call
    success_response(body)
  end

  private

  def body
    {
      balance:,
      transactions:
    }
  end

  def transactions
    db[:transactions].where(user_uuid: user[:uuid]).order(:created_at).to_a
  end

  def balance
    user[:balance]
  end

  def db
    @db ||= Db::Connection.new.connection
  end
end