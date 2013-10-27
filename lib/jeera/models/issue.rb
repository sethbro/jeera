
class Jeera::Issue
  include Her::Model

  collection_path "/search?jql=assignee=:user"
end
