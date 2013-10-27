require 'thor'

class Jira < Thor

  desc 'list', 'List issues for a project'
  def list(project = nil, user = nil)
    issues = Jeera::Issue.all(_user: user || Jeera.config.default_user)
    say issues
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
