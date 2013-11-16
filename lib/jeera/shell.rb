
class Jeera::Shell < ::Thor
  include Jeera::Util
  include Jeera::Commands::Meta
  include Jeera::Commands::Issues


  # issue
  #X - list | -s sort(priority, created, user, status, sprint, points), -u user, -p project
  # - show
  # - go/visit
  # - comment
  # - assign
  # - take
  # - fix
  # - close
  # - watch
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

  # sprint

  # end
end
