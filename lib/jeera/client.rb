require 'her'
require 'faraday'
require 'faraday_middleware'
require 'singleton'
require_relative 'auth'

# stuff = `curl -D- -u #{user}:#{Jeera.config.password} -X #{method.to_s.upcase} -H "Content-Type: application/json" #{base_url}/#{url}`

# Her::API.setup url: "https://#{Jeera.config.jira_subdomain}.jira.com/rest/api/2" do |conn|
#   # Request
#   conn.basic_auth(Jeera.config.default_user, Jeera.config.password)
#   # conn.use Jeera::Auth
#   # conn.use Faraday::Request::UrlEncoded
#   conn.user FaradayMiddleware::EncodeJson

#   # Response
#   conn.use Her::Middleware::DefaultParseJSON

#   # Adapter
#   conn.use Faraday::Adapter::NetHttp
# end


class Jeera::Client
  # include ::Singleton

  class << self
    def base_url
      @base_url || "https://#{Jeera.config.jira_subdomain}.jira.com/rest/api/2"
    end

    def call(url, method, body = '')
      conn = Faraday.new(url: base_url) do |f|
        f.basic_auth(Jeera.config.default_user, Jeera.config.password)
        f.request :json
        f.response :json #, content_type: /\bjson$/
        # f.use FaradayMiddleware::ParseJson
        #Her::Middleware::DefaultParseJSON
        # f.use Faraday.default_adapter
      end

      if method == :post
        conn.post do |req|
          req.url(url)
          req.body(body)
          debugger
        end

      elsif method == :get
        conn.post do |req|
          req.url(url)
        end
      end

    end

    def get(url, user = nil)
      call(url, :get)
    end

  end
end
