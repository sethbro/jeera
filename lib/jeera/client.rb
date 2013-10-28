require 'faraday'
require 'faraday_middleware'

# stuff = `curl -D- -u #{user}:#{Jeera.config.password} -X #{method.to_s.upcase} -H "Content-Type: application/json" #{base_url}/#{url}`

class Jeera::Client
  class << self

    def base_url
      @base_url ||= "https://#{Jeera.config.jira_subdomain}.jira.com/rest/api/2"
    end

    def connection
      conn = Faraday.new(url: base_url) do |f|
        f.basic_auth(Jeera.config.default_user, Jeera.config.password)
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.adapter :net_http
      end
    end

    def full_url(endpoint)
      "/rest/api/2/#{endpoint}"
    end

    def get(url, params = {})
      connection.get(full_url(url), params)
    end

    def post(url, body = '', params = {})
    end

    def put(url, body = '', params = {})
    end

    def delete(url, body = '')
    end

  end
end
