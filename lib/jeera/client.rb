require 'faraday'
require 'faraday_middleware'
require 'singleton'

class Jeera::Client
  include Singleton

    BASE_URL = "https://#{Jeera.config.jira_subdomain}.jira.com"

    def get(url, params = {})
      puts "Requesting #{full_url(url)}"
      connection.get(full_url(url), params)
    end

    def post(url, params = {})
      connection.post(full_url(url)) do |request|
        request.body = params
      end
    end

    def put(url, params = {})
      connection.put(full_url(url)) do |request|
        request.body = params
      end
    end

    def delete(url, body = '')
      connection.delete(full_url(url), params)
    end


    private

    def connection
      conn = Faraday.new(url: BASE_URL) do |faraday|
        faraday.basic_auth(Jeera.config.default_user, Jeera.config.password)
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter :net_http
      end
    end

    def full_url(endpoint)
      "/rest/api/2/#{endpoint}"
    end

end
