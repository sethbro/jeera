
# module Jeera
  class Jeera::Shell < Thor

    include Jeera::Commands::Issues

  # Jeera.load_thorfiles()
  # issue
  # - list
  # - show
  # - go
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
