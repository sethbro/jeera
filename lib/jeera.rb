require_relative 'jeera/version'
require_relative 'jeera/config'
require_relative 'jeera/client'

module Jeera
  # Set config instance
  # @client = Client.instance

  # class << self
  #   attr_reader :client
  # end

end

# Retrieve models
Dir[File.dirname(__FILE__) + '/jeera/models/*.rb'].each { |file| require file }

require_relative 'jira'
