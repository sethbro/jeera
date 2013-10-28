# require 'oj'
require 'thor'
require 'debugger'

require_relative 'jeera/version'
require_relative 'jeera/config'
require_relative 'jeera/client'

module Jeera
  module Commands; end

  # Set client instance
  @client = Client.instance

  class << self
    attr_reader :client
  end
end

# Get command definitions
Dir["#{File.dirname(__FILE__)}/jeera/commands/*.rb"].each { |file| require file }

require_relative 'jeera/shell'
