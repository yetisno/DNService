require 'active_record'
require 'active_support/core_ext'
require 'yaml'
require 'rubydns'

require_relative '../libs/log'
ROOT = File.expand_path(File.join('..', '..'), __FILE__)
CONFIG = YAML.load(ERB.new(File.read(File.join('config', 'dnservice.yml'))).result)['dnservice']
Dir[File.join(ROOT, 'models', '*.rb')].each { |file| require_relative file }
Dir[File.join(ROOT, 'libs', '*.rb')].each { |file| require_relative file }


require_relative 'database'
