require 'singleton'
require 'faraday'
require 'faraday_middleware'

class Jeera::Client
  include Singleton

    BASE_URL = "https://#{Jeera.config.jira_subdomain}.jira.com"

    def get(url, params = {})
      connection.get(full_url(url), params)
    end

    def post(url, body = '', params = {})
    end

    def put(url, body = '', params = {})
    end

    def delete(url, body = '')
    end


    private

    def connection
      conn = Faraday.new(url: BASE_URL) do |f|
        f.basic_auth(Jeera.config.default_user, Jeera.config.password)
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.adapter :net_http
      end
    end

    def full_url(endpoint)
      "/rest/api/2/#{endpoint}"
    end

end
