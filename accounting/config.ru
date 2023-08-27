require 'json'
require 'waterdrop'
require_relative 'lib/producer'

require File.expand_path('../config/environment', __FILE__)

required_dirs = %w[lib initializers handlers]

required_dirs.each do |rdir|
  $LOAD_PATH.unshift File.join(File.dirname(__FILE__), rdir)
end

def require_folder(folder)
  path = File.join(File.dirname(__FILE__), folder)
  Dir.entries(path).each do|file|
    next unless File.file?(File.join(path, file))
    require_relative "#{folder}/#{file}"
  end
end

%w[handlers initializers].each {|folder| require_folder(folder) }

run App