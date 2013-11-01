require 'time'
require 'active_support/ordered_hash'

module Jeera::Commands::Issues

  def self.included(thor)
    self.define_tasks(thor)
  end

  def self.define_tasks(thor)
    thor.class_eval do

      desc 'list', 'List issues for a project'
      def list(user = nil, project = nil)
        standard_issues_table(user, project)
      end

      desc 'stories', 'Story issues'
      def stories(user = nil, project = nil)
        jql :type, 'story'
        standard_issues_table(user, project)
      end

      desc 'bugs', 'Bug issues'
      def bugs(user = nil, project = nil)
        jql :type, 'bugs'
        standard_issues_table(user, project)
      end

      desc 'active', 'Issues in progress'
      def active(user = nil, project = nil)
        jql :active
        standard_issues_table(user, project)
      end


      # ===== Create/edit ===== #

      desc 'issue', 'Create new issue'
      method_option :project, aliases: '-p', desc: 'Project issue will be associated with'
      method_option :user, aliases: '-u', desc: 'User issue is assigned to'
      method_option :type, aliases: '-t', desc: 'Issue type - bug, story, etc.'
      def issue(summary)
        params = { fields: {
          summary: summary,
          issuetype: { name: (options[:type] || 'story') },
          project: { key: (options[:project] || current_project) },
        } }
        params[:fields][:assignee] = { name: options[:user] } if options[:user]

        response = Jeera.client.post('issue', params)
        if response.body
          success_message "Issue #{response.body['key']} created. - #{summary}"
        else
          error_message "Unable to create this issue"
        end
      end


      desc 'assign', 'Assign bug to user'
      def assign(issue_key, user)
        params = { fields: {
          assignee: { name: user }
        } }

        response = Jeera.client.post('issue', params)

        if response.body
          success_message "Issue #{response.body['key']} assigned to #{user}"
        else
          error_message "Assign who to what now?"
        end
      end


      private

      no_commands do

        def standard_issues_table(user = nil, project = nil)
          user ||= current_user; project ||= current_project;

          jql :user, user
          jql :open
          jql :default_sort

          parse_and_print :issues, Jeera.client.get('search', jql_output)
        end

        def issues_object(hash)
          f = hash['fields']
          obj = {
            key: hash['key'],
            url: hash['self'],
            priority: f['priority'] ? f['priority']['name'] : '-',
            summary: f['summary'],
            status: f['resolution'] ? f['resolution']['name'] : 'Open',
            assignee: f['assignee']['displayName'],
            created: Time.parse(f['created']).strftime('%b %d'),
            type: f['issuetype']['name'],
          }
        rescue => err
          say set_color("**ERROR** - #{err}", :red)
        end

        def issues_print_object(hash)
          keep = %w(key priority type summary status created)
          obj = hash.select { |k,v| keep.include?(k.to_s) }
          obj[:priority] = print_priority(obj[:priority])
          return obj.values

        rescue => err
          puts "**ERROR** - #{err}"
        end

      end

    end
  end

end
