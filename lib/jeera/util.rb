# encoding: UTF-8
require 'terminal-table'
require 'benchmark'

module Jeera::Util

  def self.included(thor)
    self.define_tasks(thor)
  end

  def self.define_tasks(thor)
    thor.class_eval do

      private
      no_commands do

        # Prepares an output array using submethods based on input "type"
        #
        # @param list_item_type [Symbol] "Type" of item dealt with, e.g. :issues
        # @return [Faraday::Response] Response from API client
        def prepare_rows(list_item_type, response)
          type = list_item_type.to_s
          normalize_method = :"#{type}_obj"
          print_method = :"#{type}_print_obj"

          items = response.body.with_indifferent_access[type].map do |item|
            self.send(normalize_method, item)
          end
        end

        def parse_and_print_table(list_item_type, response)
          print_basic_table(prepare_rows(list_item_type, response))
        end

        # Formats values for issue priority
        def print_priority(priority)
          case priority
          when 'Hotfix'
            set_color("#{priority}!!".upcase, :red, :bold, :on_white)
          when 'Urgent'
            set_color(priority.upcase, :red, :bold)
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

        # Formats values for issue status
        def print_status(status)
          color = :green if %w(Fixed Closed).include? status
          color = :yellow if %w(Open Reopened).include? status
          color = :yellow if status == 'In Progress'
          set_color(status, color)
        end


        # ===== JQL Helpers ===== #

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
            @jql << 'status not in (Icebox,Closed)'
          when :upcoming
            @jql << 'status not in (Icebox,Closed)'
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
          "order by status asc, priority, created asc"
        end

        def default_filter
          ''
        end


        # ===== API Helpers ===== #

        def current_user
          ENV['JEERA_CURRENT_USER'] || Jeera.config.default_user || no_user_error
        end

        def no_user_error
          say set_color('Error: No user specified', :red)
        end

        def current_project
          ENV['JEERA_CURRENT_PROJECT'] || Jeera.config.default_project || no_project_error
        end

        def no_project_error
          say set_color('Error: No project specified', :red)
        end

        def success_response?(response)
          puts response.to_yaml
          !response.body.respond_to? :errors
        rescue => err
          puts error_message(err)
          false
        end

        def api_error(msg, response)
          error_message(msg)
          return unless response.body['errors']

          response.body['errors'].each do |error, field|
            say error
          end
        end


        # ===== OUTPUT ===== #

        def print_out(out)
          table_styles = { border_x: '', border_y: '', border_i: '' }
          say Terminal::Table.new({ rows: [[out]], style: table_styles })
        end

        def print_basic_table(output_arr)
          table_styles = { border_x: '', border_y: '', border_i: '' }
          say Terminal::Table.new({ rows: output_arr, style: table_styles })
        end

        def error_message(msg = nil)
          msg ||= 'Unknown error'
          say set_color(msg, :red)
        end

        def success_message(msg)
          say set_color(msg, :green)
        end

        def hr(count = 96)
          '-' * count
        end

        def print_to_file(enum, filename = 'jeera_output.yml')
          f = File.open(filename, 'w')
          enum.each do |item|
            f.puts item.to_yaml
            f.puts '#-------------------------------'
            f.puts "\n\n"
          end
          f.close
        end

      end
    end
  end

end
