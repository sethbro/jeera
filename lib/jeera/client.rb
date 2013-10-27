require 'her'

Her::API.setup url: "https://#{Jeera.config.jira_subdomain}.jira.com/rest/api/2/" do |config|
  # Request
  config.use Faraday::Request::UrlEncoded
  # Response
  config.use Her::Middleware::DefaultParseJSON
  # Adapter
  config.use Faraday::Adapter::NetHttp
end
