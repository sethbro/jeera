# Middleware configuration for http://github.com/remiprev/her

Her::API.setup url: "https://#{Jeera.config.jira_subdomain}.jira.com/rest/api/2" do |conn|
  # Request
  conn.basic_auth(Jeera.config.default_user, Jeera.config.password)
  conn.user FaradayMiddleware::EncodeJson

  # Response
  conn.use Her::Middleware::DefaultParseJSON

  # Adapter
  conn.use Faraday::Adapter::NetHttp
end
