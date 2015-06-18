require 'active_record'
require 'active_support/core_ext'
ROOT = File.expand_path(File.join('..', '..'), __FILE__)
CONFIG = YAML.load(ERB.new(File.read('dnservice.yml')).result)['dnservice']
Dir[File.join(ROOT, 'models', '*.rb')].each { |file| require_relative file }

require_relative 'database'
