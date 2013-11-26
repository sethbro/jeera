require 'active_support/core_ext/hash'
require 'awesome_print'
require 'time'

module Jeera::Commands::Issues

  def self.included(thor)
    self.define_tasks(thor)
  end

  def self.define_tasks(thor)
    thor.class_eval do

      # ===== Issue Lists ===== #

      # == LIST
      desc :list, 'List issues for a project'
      def list(user = nil, project = nil)
        response = issues_call(user, project)
        parse_and_print_table(:issues, response)
      end

      # == STORIES
      desc :stories, 'Story issues'
      def stories(user = nil, project = nil)
        jql :type, 'story'

        response = issues_call(user, project)
        parse_and_print_table(:issues, response)
      end

      # == BUGS
      desc :bugs, 'Bug issues'
      def bugs(user = nil, project = nil)
        jql :type, 'bugs'

        response = issues_call(user, project)
        parse_and_print_table(:issues, response)
      end

      # == ACTIVE
      desc :active, 'Issues in progress'
      def active(user = nil, project = nil)
        jql :active

        response = issues_call(user, project)
        parse_and_print_table(:issues, response)
      end

      # ===== Issue Details ===== #

      # == SHOW
      desc :show, 'Details about an issue'
      def show(issue_key)
        response = Jeera.client.get(issue_endpoint(issue_key))
        issue = issue_obj(response.body.with_indifferent_access)

        comments = issue[:comments]
        comments = (comments && ! comments.empty?) ? comment_section(comments) : ''

        say ["\n", issue_header(issue), issue[:description], "\n", comments].join("\n")
      end


      # == GO/BROWSE
      desc :go, 'Opens issue page in browser'
      def go(issue_key)
      `open #{browse_issue_url(issue_key)}`
      end


      # ===== Issue Manipulation ===== #

      # == CREATE
      desc :issue, 'Create new issue'
      # method_option :project, aliases: '-p', desc: 'Project issue will be associated with'
      # method_option :user, aliases: '-u', desc: 'User assigned to issue (assignee)'
      # method_option :type, aliases: '-t', desc: 'Issue type - bug, story, etc.'

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

      # == ASSIGN
      desc :assign, 'Assign bug to user'
      def assign(issue_key, user)
        params = { fields: { assignee: { name: user } } }
        response = Jeera.client.post(issue_endpoint(issue_key), params)

        if success_response? response
          success_message "Issue #{response.body['key']} assigned to #{user}"
        else
          error_message "Assign who to what now?"
        end
      end

      # == FIX
      desc :fix, 'Mark issue as resolved'
      def fix(issue_key)
        params = { fields: { status: { name: 'Fixed' } } }
        response = Jeera.client.put(issue_endpoint(issue_key), params)

        if success_response? response
          success_message "The fix is in. Issue #{response.body['key']} resolved."
        else
          error_message "No can do. Issue #{issue_key} is still broken."
        end
      end

      # == START
      desc :start, 'Mark issue as in progress'
      def start(issue_key)
        params = { fields: { status: { name: 'In Progress' } } }
        response = Jeera.client.put(issue_endpoint(issue_key), params)

        if success_response? response
          success_message "Glad to hear you're on the case."
        else
          error_message "Your enthusiasm is appreciated. Just not right now."
        end
      end

      # == STOP
      desc :stop, 'Stop progress on an issue'
      def stop(issue_key)
        params = { fields: { status: { name: '' } } }
        response = Jeera.client.put(issue_endpoint(issue_key), params)

        if success_response? response
          success_message "The fix is in. Issue #{response.body['key']} resolved."
        else
          error_message "No way. You can't quit now, #{Jeera.config.default_user}!"
        end
      end

      # == CLOSE
      desc :close, 'Close issue'
      def close(issue_key)
        params = { fields: { status: { name: 'Closed' } } }
        response = Jeera.client.post(issue_endpoint(issue_key), params)

        if success_response? response
          success_message "Issue #{response.body['key']} closed"
        else
          error_message "Could not close"
        end
      end


      private
      no_commands do

        # Makes an API issue search call with standard options
        #
        # @param user [String] User key to filter issues by
        # @param project [String] Project key to filter issues by
        # @return [Hash] Normalized hash
        def issues_call(user = nil, project = nil)
          user ||= current_user; project ||= current_project;

          jql :user, user
          jql :open
          jql :default_sort

          Jeera.client.get('search', jql_output)
        end

        # Normalizes API response for single issue for issue table display
        #
        # @param hash [Hash] Issue response hash from API
        # @return [Hash] Normalized hash
        def issues_obj(hash)
          f = hash[:fields]

          # NOTE: Order is important here!
          obj = {
            key: hash['key'],
            priority:    f[:priority] ? f[:priority][:name] : '-',
            summary: f[:summary].scan(/.{1,120}\b[\.),!"']*|.{1,120}/).join("\n"),
            type:         f[:issuetype][:name],
            created:    Time.parse(f[:created]).strftime('%b %d'),
            status:      f[:status] ? f[:status][:name] : 'Open',
          }

          # Additional formatting
          obj[:priority] = print_priority(obj[:priority])
          obj[:status] = print_status(obj[:status])

          obj.values
        rescue => err
          error_message(err)
        end

        # Normalizes API response for single issue for issue detail display
        #
        # @param hash [Hash] Issue response hash from API
        # @return [Hash] Normalized hash
        def issue_obj(hash)
          f = hash[:fields]

          # NOTE: Order is important here!
          obj = {
            key: hash['key'],
            priority:        f[:priority] ? f[:priority][:name] : '-',
            summary:     f[:summary],
            description:  f[:description],
            type:             f[:issuetype][:name],
            created:        Time.parse(f[:created]).strftime('%b %d'),
            status:          f[:status] ? f[:status][:name] : 'Open',
            assignee:      f[:assignee][:displayName],
            reporter:       f[:reporter][:displayName],
            comments:   f[:comment],
            labels:          f[:labels],
          }

          # Additional formatting
          obj[:priority] = print_priority(obj[:priority])
          obj[:status] = print_status(obj[:status])

          obj
        rescue => err
          error_message(err)
        end

        # Issue details (key, status, summary, etc) formatted for individual issue display
        def issue_header(issue_hash)
          info = [issue_hash[:key], issue_hash[:type], print_priority(issue_hash[:priority]), print_status(issue_hash[:status])]
          [info.join(' | '), issue_hash[:summary], hr].join("\n")
        end

        # Formatted output for all comments
        def comment_section(comments_hash)
          return set_color('No comments', :cyan) unless comments_hash[:total] > 0

          sec = ['Comments', hr]
          comments_hash[:comments].each do |cmt|
            sec << comment(cmt)
          end

          sec.join("\n")
        end

        # Formatted output for an individual comment
        def comment(comment_hash)
            time = Time.parse(comment_hash[:updated]).strftime('%b %d %H:%m')
            author = set_color(" -- #{comment_hash[:author][:name]}", :cyan)
            byline = "#{author} | #{time}\n"

            [comment_hash[:body], byline].join("\n")
        end

        # Returns url endpoint for an issue, defaulting to active project if needed
        def issue_endpoint(issue_key)
          "issue/#{issue_project_key(issue_key)}"
        end

        # Returns an issue key based on active project if no project specified
        def issue_project_key(issue_key)
          issue_key.split('-').length > 1 ? issue_key : [current_project, issue_key].join('-')
        end

        def browse_issue_url(issue_key)
          "https://#{Jeera.config.jira_subdomain}.jira.com/browse/#{issue_project_key(issue_key)}"
        end

      end
    end
  end
end
