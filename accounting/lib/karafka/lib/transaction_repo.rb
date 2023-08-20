require 'securerandom'

class TransactionRepo
  attr_accessor :data

  def initialize(data)
    @data = data
  end

  def withdraw_transaction
    raise 'NoTask' unless assign_price

    transaction_data = nil
    db.transaction do
      user = db[:users].for_update.first(uuid: data[:user_uuid])
      raise 'NoUser' unless user

      balance = user[:balance] - assign_price
      db[:users].where(uuid: data[:user_uuid]).update(balance: balance)

      transaction_data = {
        uuid: SecureRandom.uuid,
        credit: assign_price,
        debit: 0,
        type: 'withdrawal',
        user_uuid: data[:user_uuid],
        desc: "Withdrawal for task assignment '#{task[:uuid]} - #{task[:title]}'",
        created_at: Time.now
      }
      db[:transactions].insert(transaction_data)
    end

    transaction_data
  end

  def deposit_transaction
    raise 'NoTask' unless resolve_price

    transaction_data = nil
    db.transaction do
      user = db[:users].for_update.first(uuid: data[:user_uuid])
      raise 'NoUser' unless user

      balance = user[:balance] + resolve_price
      db[:users].where(uuid: data[:user_uuid]).update(balance: balance)
      transaction_data = {
        uuid: SecureRandom.uuid,
        credit: 0,
        debit: resolve_price,
        type: 'deposit',
        user_uuid: data[:user_uuid],
        desc: "Deposit for task resolving '#{task[:uuid]} - #{task[:title]}'",
        created_at: Time.now
      }
      db[:transactions].insert(transaction_data)
    end

    transaction_data
  end

  def payment_transaction
    transaction_cleaning_uuid = []
    transaction_data = nil
    db.transaction do
      user = db[:users].for_update.first(uuid: data[:user_uuid])
      raise 'NoUser' unless user

      balance_for_payment = user[:balance]
      if balance_for_payment > 0
        db[:users].where(uuid: data[:user_uuid]).update(balance: 0)
        transaction_data = {
          uuid: SecureRandom.uuid,
          credit: balance_for_payment,
          debit: 0,
          type: 'payment',
          user_uuid: data[:user_uuid],
          desc: "Day Payment at #{data[:finished_at]}",
          created_at: Time.now,
          finished_at: data[:finished_at]
        }
        db[:transactions].insert(transaction_data)
      end
      transaction_cleaning_uuid = db[cleaning_uuids_sql].all.map{|i| i[:uuid]}
      db[close_transactions_sql].all

      # TODO: congratz popug with email
    end

    [transaction_data, transaction_cleaning_uuid]
  end

  private

  def cleaning_uuids_sql
    "SELECT uuid FROM transactions WHERE type in ('deposit','withdrawal') " \
    "AND finished_at IS NULL AND user_uuid='#{data[:user_uuid]}' AND created_at < '#{data[:finished_at]}'"
  end

  def close_transactions_sql
    "UPDATE transactions SET finished_at='#{data[:finished_at]}' "\
    "WHERE type in ('deposit','withdrawal') AND finished_at IS NULL AND user_uuid='#{data[:user_uuid]}'"
  end

  def assign_price
    task&.dig(:assign_price)
  end

  def resolve_price
    task&.dig(:resolve_price)
  end

  def task
    @task ||= db[:tasks].first(uuid: data[:task_uuid])
  end

  def db
    @db ||= Db::Connection.new.connection
  end
end