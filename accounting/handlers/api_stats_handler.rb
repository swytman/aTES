require_relative 'base_handler'

class ApiStatsHandler < BaseHandler
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def call
    return no_access_error unless user_accountant_or_admin?

    success_response(body)
  end

  private

  def user_accountant_or_admin?
    user[:role] == 'accountant' || user[:role] == 'admin'
  end

  def body
    {
      today_balance:,
      company_balance_by_day:
    }
  end

  def company_balance_by_day
    db[balance_by_day_sql].to_a
  end

  def today_balance
    db[today_balance_sql].first[:balance] || 0
  end

  def today_balance_sql
    "SELECT sum(credit)-sum(debit) as balance "\
    "FROM transactions WHERE type IN ('deposit', 'withdrawal') AND finished_at IS NULL"
  end

  def balance_by_day_sql
    "SELECT sum(credit)-sum(debit) as balance, finished_at "\
    "FROM transactions WHERE type IN ('deposit', 'withdrawal') AND finished_at IS NOT NULL "\
    "GROUP BY finished_at ORDER BY finished_at DESC"
  end


  def last_payment
    db["SELECT max(created_at) as max FROM transactions WHERE type='payment'"].first[:max]
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