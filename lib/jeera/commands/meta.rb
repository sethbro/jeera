# encoding: UTF-8
require 'time'

module Jeera::Commands::Meta

  def self.included(thor)
    self.define_tasks(thor)
  end

  def self.define_tasks(thor)
    thor.class_eval do

      # ===== PROJECTS ===== #
      desc :projects, 'List available projects'
      def projects
        response = Jeera.client.get '/project'

        if success_response?(response)
          print_to_file(response, 'projects.yml')
        else
          error_message
        end
      end

      desc :project, 'List or change current project'
      def project(project_id_or_key = nil)
        if project_id_or_key
          ENV['JEERA_CURRENT_PROJECT'] = project_id_or_key
        end
        say "Current project is #{current_project}"
      end

      desc :statuses, 'List available status types. Per project'
      def statuses(project_id_or_key = nil)
        project_id_or_key ||= current_project
        response = Jeera.client.get("project/#{project_id_or_key}/statuses")

        if success_response?(response)
          print_to_file(response.body, 'statuses.yml')
        else
          error_message
        end
      end

      desc :transitions, 'List available issue transition types'
      def transitions(issue_key, project_id_or_key = nil)
        project_id_or_key ||= current_project
        response = Jeera.client.get("issue/#{project_id_or_key}-#{issue_key}/transitions")

        if success_response?(response)
          print_to_file(response.body, 'transitions.yml')
        else
          error_message
        end
      end

      desc :fields, 'List available fields. Per project'
      def fields
        response = Jeera.client.get("field")

        if success_response?(response)
          print_table(response.body, 'fields.yml')
        else
          error_message
        end
      end

      desc :resolutions, 'List available resolution types. Per project'
      def resolutions(project_id_or_key = nil)
        project_id_or_key ||= current_project
        response = Jeera.client.get("/resolution")

        if success_response?(response)
          print_table(response.body, 'resolutions.yml')
        else
          error_message
        end
      end

      desc :users, 'List system users'
      def users
        response = Jeera.client.get 'user/assignable/multiProjectSearch'

        if success_response?(response)
          print_table(response.body, 'users.yml')
        else
          error_message
        end
      end

      desc :user, 'List or change current user'
      def user(username = nil)
        ENV['JEERA_CURRENT_USER'] = username if username
        user_out = username ? "now #{current_user}" : current_user
        say "Current user is #{user_out}"
      end


      private

      no_commands do

        def resolution_obj(res)
        end

        def status_obj(status)
        end

      end

    end
  end

end