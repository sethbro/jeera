require 'active_support/core_ext/hash/keys'

module Jeera::Commands::Util

  def self.included(thor)
    self.define_tasks(thor)
  end

  def self.define_tasks(thor)
    thor.class_eval do

      private

      no_commands do

        def current_user
          ENV['JEERA_CURRENT_USER'] || Jeera.config.default_user || no_user_error
        end

        def current_project
          ENV['JEERA_CURRENT_PROJECT'] || Jeera.config.default_project || no_project_error
        end

        def no_project_error
          say set_color('Error: No project specified', :red)
        end

        def no_user_error
          say set_color('Error: No user specified', :red)
        end

        def parse_and_print(list_item_type, response)
          type = list_item_type.to_s
          items = response.body[type].map do |item|
            self.send :"#{type}_object", item
          end

          output_array = items.inject([]) do |output_arr, item|
            output_arr << self.send(:"#{type}_print_object", item)
          end

          print_table(output_array)
        end

        def print_priority(priority)
          case priority
          when 'Urgent'
            set_color("#{priority}\t", :white, :on_red)
          when 'High'
            set_color(priority, :red)
          when 'Normal'
            set_color(priority, :yellow)
          when 'Low'
            set_color(priority, :cyan)
          else
            priority
          end
        end

        # Adds a JQL statement to an internally managed array
        #
        # @param key [Symbol] A key used internally to determine JQL syntax
        # @param arg [String] An optional argument used in JQL value
        # @return [Array] The array of JQL statements added so far
        def jql(key, arg = nil)
          @jql ||= []

          case key
          when :user
            @jql << "assignee=#{arg}"
          when :type
            @jql << "issuetype=#{arg}"
          when :active
            @jql << "status='In Progress'"
          when :open
            @jql << 'status not in (Icebox,Backlog,Closed)'
          when :default_filter
            @jql << default_filter
          when :default_sort
            @jql << default_sort
          else
            @jql << "#{key}=#{arg}"
          end

          @jql
        end

        # Joins and outputs the JQL statement built up so far
        #
        # @return [Hash] A hash where the value is the JQL output
        def jql_output
          @jql[1..-1].each_with_index do |clause, i|
            pre = (clause =~ /^order by/) ? ' ' : '&'
            clause.prepend(pre)
          end

          { jql: @jql.join }
        end

        def sort_string(*args)
          "order by #{args.join(',')}"
        end


        def default_sort
          "order by status asc,priority,created asc"
        end

        def default_filter
          ''
        end

        def print_to_file(enum, filename = 'jeera_output.yml')
          f = File.open('issues.yaml', 'w')
          enum.each do |item|
            f.puts item.to_yaml
            f.puts '#-------------------------------'
            f.puts "\n\n"
          end
          f.close
        end
      end

      def error_message(msg)
        say set_color(msg, :red)
      end

      def success_message(msg)
        say set_color(msg, :green)
      end

    end
  end

end
