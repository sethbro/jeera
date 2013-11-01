require 'time'
require 'active_support/core_ext/hash'

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

      desc 'show', 'Details about an issue'
      def show(issue_key)
        response = Jeera.client.get(issue_endpoint(issue_key))
        issue = issue_object(response.body)
        # puts issue.to_yaml
        say ''
        say "#{issue[:key]} | #{issue[:summary]}"
        say "#{'=' * 96}\n"
        say "#{issue[:type]} | #{issue[:status]} | #{issue[:reporter]}"
        # say issue[:labels].join(' ')
        say ''

        begin
          print_wrapped(issue[:description].strip!)
        rescue
          puts issue[:description]
        end

        comment_section(issue[:comments])
      end


      # ===== Create/edit ===== #

      desc 'issue', 'Create new issue'

      method_option :project, aliases: '-p', desc: 'Project issue will be associated with'
      method_option :user, aliases: '-u', desc: 'User assigned to issue (assignee)'
      method_option :type, aliases: '-t', desc: 'Issue type - bug, story, etc.'

      def issue(summary)
        params = { fields: {
          summary: summary,
          issuetype: { name: (options[:type] || 'story') },
          project: { key: (options[:project] || current_project) },
        } }
        params[:fields][:assignee] = { name: options[:user] } if options[:user]

        response = Jeera.client.post('issue', params)
        if success_response? response
          success_message "Issue #{response.body['key']} created. - #{summary}"
        else
          error_message "Unable to create this issue"
        end
      end

      desc 'assign', 'Assign bug to user'
      def assign(issue_key, user)
        params = { fields: { assignee: { name: user } } }
        response = Jeera.client.post(issue_endpoint(issue_key), params)

        if success_response? response
          success_message "Issue #{response.body['key']} assigned to #{user}"
        else
          error_message "Assign who to what now?"
        end
      end

      desc 'fix', 'Mark issues as resolved'
      def fix(issue_key)
        params = { fields: { status: { name: 'Fixed' } } }
        response = Jeera.client.put(issue_endpoint(issue_key), params)


        if success_response? response
          success_message "Issue #{response.body['key']} fixed"
        else
          error_message "No that still broken"
        end
      end

      desc 'close', 'Close issue'
      def close(issue_key)
        params = { fields: { status: { name: 'Closed' } } }
        response = Jeera.client.post(issue_endpoint(issue_key), params)
        # puts response.body

        if success_response? response
          success_message "Issue #{response.body['key']} closed"
        else
          error_message "Could not close"
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

        def comment_section(comments_hash)
          if comments_hash[:total] > 0
            say ''
            say 'Comments'
            say "#{'~' * 96}\n"
            # puts comments_hash[:comments].to_yaml

            comments_hash[:comments].each do |comment|
              say ''
              print_wrapped comment[:body]
              say "#{comment[:author][:name]} | #{Time.parse(comment[:updated]).strftime('%b %d %H:%m')}  "
              say ''
            end
          else
            set_color 'No comments', :red
          end
        end

        # Normalizes single issue API response into a hash ready for display in issue list
        #
        # @param hash [Hash] Issue response hash from API
        # @return [Hash] Normalized hash
        def issues_object(hash)
          h = hash.with_indifferent_access
          f = h[:fields]

          obj = {
            key: h[:key],
            url: h[:self],
            created:      Time.parse(f[:created]).strftime('%b %d'),
            summary:    f[:summary],
            priority:       f[:priority] ? f[:priority][:name] : '-',
            status:         f[:status] ? f[:status][:name] : 'Open',
            assignee:     f[:assignee][:displayName],
            severity:       f[:severity],
            type:             f[:issuetype][:name],
          }.with_indifferent_access

        rescue => err
          say set_color("**ERROR** - #{err}", :red)
        end

        # Turns issue API hash into array of arrays ready for table display
        #
        # @param hash [Hash] Normalized issue hash
        # @return [Array] D hash
        def issues_print_object(hash)
          cols = %w(key priority type summary status created severity)
          obj = hash.select { |k, v| cols.include?(k.to_s) }
          obj[:priority] = print_priority(obj[:priority])

          return obj.values

        rescue => err
          error_message "**ERROR** - #{err}"
        end

        # Normalizes single issue API response into a hash geared towards issue details display
        #
        # @param hash [Hash] Issue response hash from API
        # @return [Hash] Normalized hash
        def issue_object(hash)
          h = hash.with_indifferent_access
          f = h[:fields]

          obj = {
            key: h[:key],
            url: h[:self],
            created:          Time.parse(f[:created]).strftime('%b %d'),
            summary:        f[:summary],
            description:    f[:description],
            type:                f[:issuetype][:name],
            status:             f[:status] ? f[:status][:name] : 'Open',
            priority:           f[:priority] ? f[:priority][:name] : '-',
            assignee:        f[:assignee][:displayName],
            reporter:         f[:reporter][:displayName],
            comments:      f[:comment],
            labels:             f[:labels],
          }.with_indifferent_access

        rescue => err
          error_message "**ERROR** - #{err}"
        end

        def issue_endpoint(issue_key)
          "issue/#{issue_project_key(issue_key)}"
        end

        def issue_project_key(issue_key)
          issue_key.split('-').length > 1 ? issue_key : [current_project, issue_key].join('-')
        end

        def success_response?(response)
          response.body['errors'].blank?
        end

      end

    end
  end

end
