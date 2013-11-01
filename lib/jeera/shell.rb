
class Jeera::Shell < ::Thor
  include Jeera::Commands::Util
  include Jeera::Commands::Meta
  include Jeera::Commands::Issues

  # issue
  # - list | -s sort(priority, created, user, status, sprint, points), -u user, -p project
  # - show
  # - go/visit
  # - comment
  # - assign
  # - take
  # - fix
  # - close
  # - tag
  # - mine
  # - start
  # - stop
  # - search
  # - priority (helper methods for priority names?)

  # project
  # - current
  # - switch
  # - default

  # team
  # - current (sprint points/total)
  # -

  # sprint
  # -

  # desc 'issue', 'Create a new issue'
  # assignee
  # def issue(desc, opts = {})
  # end

  # desc 'assign', 'Assign an issue to a user'
  # def assign(issue_id, user_id)
  # end

  # desc 'search', 'Search issues'
  # def search(keyword, opts = {})
  # end

  # end
end
