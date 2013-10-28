require 'oj'
require 'thor'
require_relative 'jeera/client'

class Jira

  def projects
    Jeera::Client.get '/project'
  end

  # desc 'list', 'List issues for a project'
  def list(project = nil, user = nil)
    user ||= Jeera.config.default_user
    # url = "search?jql=assignee=#{user}"
    # results =  Jeera.client.get(url, user)
    # debugger
    # begin
      # x = Jeera::Issue.all(_user: user || Jeera.config.default_user)

    # # conn = Faraday.new(:url => 'https://unlockdata.jira.com') do |faraday|
    # #   # faraday.request  :url_encoded             # form-encode POST params
    # #   # faraday.response :logger                  # log requests to STDOUT
    # #   faraday.basic_auth('seth', 'N0t2Gu3sS')
    # #   faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
    # # end

    # debugger
    # x = conn.get '/rest/api/2/project'
    # debugger


    # rescue => e
    #   debugger
    # end
    # say Oj.load(issues)
  end

  # desc 'issue', 'Create a new issue'
  # def issue(desc, opts = {})
  # end

  # desc 'assign', 'Assign an issue to a user'
  # def assign(issue_id, user_id)
  # end

  # desc 'search', 'Search issues'
  # def search(keyword, opts = {})
  # end

end
