
module Jeera::Commands::Issues

  def self.included(thor)
    thor.class_eval do

      desc 'projects', 'List available projects'
      def projects
        Jeera.client.get '/project'
      end

      # == LIST ISSUES == #
      desc 'list', 'List issues for a project'
      def list(project = nil, user = nil)
        user ||= Jeera.config.default_user
        response = Jeera.client.get('/search', { jql: "assignee=#{user}" })
        issues = response.body['issues']

        output_array = issues.inject([]) do |output_arr, issue|
          output_arr << issue_object(issue)
        end

        debugger

        print_table output_array
      end


      private

      no_commands do

        def issue_object(hash)
          # debugger
          f = hash['fields']

          { id: hash['id'],
            key: hash['key'],
            url: hash['self'],
            summary: f['summary'],
            type: f['issuetype']['name'],
            status: f['resolution']['name'],
            reporter: f['reporter']['displayName'],
            priority: f['priority']['name'],
            created: f['created'],
            # labels:
            # fix_version:
          }
        rescue => err
          debugger
        end

      end

    end
  end

end
