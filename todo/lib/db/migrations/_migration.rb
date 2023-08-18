module Db
  class Migration
    attr_accessor :connection, :key

    def initialize(key)
      @key = key
      @connection = Db::Connection.new.connection
    end

    def call
      raise 'BlockRequired' unless block_given?

      with_migrated do
        yield
      end
    end

    private

    def with_migrated
      migrations =  connection.from(:migrations).all
      MyLogger.info "#{key} migration started!"

      yield
      MyLogger.info "#{key} migration finished!"
    end

    def migrate
      raise NotImplementedError
    end
  end
end