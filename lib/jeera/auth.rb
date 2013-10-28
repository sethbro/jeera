require 'base64'

class Jeera::Auth < Faraday::Middleware
  def call(env)
    # debugger
    auth = [Jeera.config.default_user, Jeera.config.password].join(':').gsub("\n", '')
    env[:request_headers]['Authentication'] = "Basic #{Base64.encode64(auth)}".strip

    debugger
    @app.call(env)
  end

end
