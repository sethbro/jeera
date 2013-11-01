require 'time'

module Jeera::Commands::Meta

  def self.included(thor)
    self.define_tasks(thor)
  end

  def self.define_tasks(thor)
    thor.class_eval do

      # ===== PROJECTS ===== #
      desc 'projects', 'List available projects'
      def projects
        response = Jeera.client.get '/project'
        puts response.to_yaml
      end

      desc 'project', 'List or change current project'
      def project(project_id_or_key = nil)
        if project_id_or_key
          ENV['JEERA_CURRENT_PROJECT'] = project_id_or_key
        end
        say "Current project is #{current_project}"
      end

      desc 'statuses', 'List available status types. Per project'
      def statuses(project_id_or_key)
        response = Jeera.client.get("project/#{project_id_or_key}/statuses")
        puts response.body.to_yaml
      end

      desc 'users', 'List system users'
      def users
        response = Jeera.client.get 'user/search?username=seth'
      end

      desc 'user', 'List or change current user'
      def user(username = nil)
        if username
          ENV['JEERA_CURRENT_USER'] = username
        end
        say "Current user is #{current_user}"
      end

    end
  end

end