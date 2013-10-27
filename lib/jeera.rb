require_relative 'jeera/version'
require_relative 'jeera/config'
require_relative 'jeera/client'

# Retrieve models
Dir[File.dirname(__FILE__) + '/jeera/models/*.rb'].each { |file| require file }

require_relative 'jira'
