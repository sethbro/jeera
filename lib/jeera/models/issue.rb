
class Jeera::Issue
  include ::Her::Model

  class << self

    def list(user = nil)
      user ||= Jeera.config.default_user
      post "/rest/api/2/search", { "jql" => "assignee=#{user}" }
      # get "/search?jql=assignee=#{user}"
    end

  end

end
