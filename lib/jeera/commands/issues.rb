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
