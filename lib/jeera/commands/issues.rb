
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

        issues = response.body['issues'].map { |iss| issue_object(iss) }
        output_array = issues.inject([]) do |output_arr, issue|
          output_arr << print_object(issue)
        end

        print_table(output_array)
      end


      private

      no_commands do

        def issue_object(hash)
          obj = { id: hash['id'], key: hash['key'], url: hash['self'] }
          f = hash['fields']

          obj.update({
            summary: f['summary'],
            type: f['issuetype']['name'],
            status: f['resolution'] ? f['resolution']['name'] : 'Open',
            reporter: f['reporter']['displayName'],
            priority: f['priority']['name'],
            created: Time.new(f['created']).strftime('%b %d'),
          })
        rescue => err
          puts err
          # debugger
        end

        def print_object(hash)
          keep = %w(key type priority summary created status)
          hash.select { |k,v| keep.include?(k.to_s) }.values
        rescue => err
            puts err
        end

      end

    end
  end

end
