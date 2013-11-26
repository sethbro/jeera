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
        # puts response.body.to_yaml
        success_response?(response) ? print_to_file(response, 'projects.yml') : error_message
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
        success_response?(response) ? print_to_file(response, 'statuses.yml') : error_message
      end

      desc :fields, 'List available fields. Per project'
      def fields
        response = Jeera.client.get("field")
        success_response?(response) ? print_to_file(response.body, 'fields.yml') : error_message
      end

      desc :resolutions, 'List available resolution types. Per project'
      def resolutions(project_id_or_key = nil)
        project_id_or_key ||= current_project
        response = Jeera.client.get("/resolution")
        # puts response.body.to_yaml
        success_response?(response) ? print_table(response.body, 'resolutions.yml') : error_message
      end

      desc :users, 'List system users'
      def users
        response = Jeera.client.get 'user/assignable/multiProjectSearch'
        # puts response.body.to_yaml
        success_response?(response) ? print_to_file(response, 'users.yml') : error_message
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