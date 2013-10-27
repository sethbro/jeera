require 'yaml'
require 'singleton'
require 'debugger'

module Jeera
  class Config
    include ::Singleton

    FILE = "#{`echo ~`.strip}/.jeera"

    def initialize
      config = YAML.load_file(FILE)
      config.each do |key, value|
        instance_variable_set :"@#{key}", value
        self.class.send :attr_reader, key.to_sym
      end
    end
  end

  # Set config instance
  @config = Config.instance

  class << self
    attr_reader :config
  end
end
