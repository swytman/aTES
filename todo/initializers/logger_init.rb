require 'logger'
$stdout.sync = true

class MyLogger
  def initialize
    @@logger ||= Logger.new(STDOUT)
  end

  def self.info(message)
    @@logger.fatal message
  end
end

MyLogger.new