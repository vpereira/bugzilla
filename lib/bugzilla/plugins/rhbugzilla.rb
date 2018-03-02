# rhbugzilla.rb
# Copyright (C) 2010-2012 Red Hat, Inc.
#
# Authors:
#   Akira TAGOH  <tagoh@redhat.com>
#
# This library is free software: you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rubygems'

# begin
#  gem 'ruby-bugzilla'
# rescue Gem::LoadError
#  require File.join(File.dirname(__FILE__), "..", "bugzilla.rb")
# end

module Bugzilla
  module Plugin
    class RedHat < ::Bugzilla::Plugin::Template
      def initialize
        super

        @hostname = 'bugzilla.redhat.com'
      end # def initialize

      def parserhook(*args)
        parser, argv, opts, *etc = args
        parser.separator ''
        parser.separator 'RH Bugzilla specific options:'
        parser.on('--cc=EMAILS', 'filter out the result by Cc in bugs') { |v| opts[:query][:cc] ||= []; opts[:query][:cc].push(*v.split(',')) }
        parser.on('--filterversion=VERSION', 'filter out the result by the version in bugs') { |v| opts[:query][:version] ||= []; opts[:query][:version].push(*v.split(',')) }
      end # def parserhook

      def prehook(*args)
        cmd, opts, *etc = args
        case cmd
        when :search
          # This parameter is Red Hat Extension
          # See https://bugzilla.redhat.com/docs/en/html/api/Bugzilla/WebService/Bug.html#search
          opts[:query_format] = 'advanced'
          extra_field = 0

          if opts.include?(:status)
            opts[:bug_status] = opts[:status]
            opts.delete(:status)
          end
          if opts.include?(:id)
            opts[:bug_id] = opts[:id]
            opts.delete(:id)
          end
          opts[:bug_severity] = opts[:severity] if opts.include?(:severity)
          if opts.include?(:summary)
            opts[:short_desc] = opts[:summary]
            opts.delete(:summary)
          end
          if opts.include?(:cc)
            # CC should be parsed "any words" by default
            opts[eval(':emailcc1')] = 1
            opts[eval(':emailtype1')] = :anywordssubstr
            opts[eval(':email1')] = opts[:cc]
            opts.delete(:cc)
          end
          if opts.include?(:creation_time)
            opts[format('field0-%d-0', extra_field)] = :creation_ts
            opts[format('type0-%d-0', extra_field)] = :greaterthan
            opts[format('value0-%d-0', extra_field)] = opts[:creation_time]
            opts.delete(:creation_time)
          end
        when :metrics
          metricsopts = etc[0]
          extra_field = 0

          if opts.include?(:status)
            opts[:bug_status] = opts[:status]
            opts.delete(:status)
          end
          if opts.include?(:id)
            opts[:bug_id] = opts[:id]
            opts.delete(:id)
          end
          opts[:bug_severity] = opts[:severity] if opts.include?(:severity)
          if opts.include?(:summary)
            opts[:short_desc] = opts[:summary]
            opts.delete(:summary)
          end
          if opts.include?(:cc)
            i = 1
            opts[:cc].each do |e|
              opts[eval(":emailcc#{i}")] = 1
              opts[eval(":emailtype#{i}")] = :substring
              opts[eval(":email#{i}")] = e
            end
            opts.delete(:cc)
          end

          if opts.include?(:creation_time)
            if opts[:creation_time].is_a?(Array)
              opts[format('field0-%d-0', extra_field)] = :creation_ts
              opts[format('type0-%d-0', extra_field)] = :greaterthan
              opts[format('value0-%d-0', extra_field)] = opts[:creation_time][0]
              extra_field += 1
              opts[format('field0-%d-0', extra_field)] = :creation_ts
              opts[format('type0-%d-0', extra_field)] = :lessthan
              opts[format('value0-%d-0', extra_field)] = opts[:creation_time][1]
              extra_field += 1
            else
              opts[format('field0-%d-0', extra_field)] = :creation_ts
              opts[format('type0-%d-0', extra_field)] = :greaterthan
              opts[format('value0-%d-0', extra_field)] = opts[:creation_time]
              extra_field += 1
            end
            opts.delete(:creation_time)
          end
          if opts.include?(:last_change_time)
            if opts[:last_change_time].is_a?(Array)
              opts[:chfieldfrom] = opts[:last_change_time][0]
              opts[:chfieldto] = opts[:last_change_time][1]
              if opts[:bug_status] == 'CLOSED'
                opts[format('field0-%d-0', extra_field)] = :bug_status
                opts[format('type0-%d-0', extra_field)] = :changedto
                opts[format('value0-%d-0', extra_field)] = opts[:bug_status]
                extra_field += 1
              end
            end
            opts.delete(:last_change_time)
          end
          if opts.include?(:metrics_closed_after)
            opts[format('field0-%d-0', extra_field)] = :bug_status
            opts[format('type0-%d-0', extra_field)] = :changedafter
            opts[format('value0-%d-0', extra_field)] = opts[:metrics_closed_after]
            extra_field += 1
            opts.delete(:metrics_closed_after)
          end
          if opts.include?(:metrics_not_closed)
            opts[format('field0-%d-0', extra_field)] = :bug_status
            opts[format('type0-%d-0', extra_field)] = :notequals
            opts[format('value0-%d-0', extra_field)] = 'CLOSED'
            extra_field += 1
            opts[format('field0-%d-0', extra_field)] = :creation_ts
            opts[format('type0-%d-0', extra_field)] = :lessthan
            opts[format('value0-%d-0', extra_field)] = opts[:metrics_not_closed]
            extra_field += 1
            opts.delete(:metrics_not_closed)
          end
       end
      end # def prehook

      def posthook(*args)
        cmd, opts, *etc = args
        case cmd
        when :search
          if opts.include?('bugs')
            opts['bugs'].each do |bug|
              if bug.include?('bug_status')
                bug['status'] = bug['bug_status']
                bug.delete('bug_status')
              end
              if bug.include?('bug_id')
                bug['id'] = bug['bug_id']
                bug.delete('bug_id')
              end
              if bug.include?('bug_severity')
                bug['severity'] = bug['bug_severity']
                bug.delete('bug_severity')
              end
              if bug.include?('short_desc')
                bug['summary'] = bug['short_desc']
                bug.delete('short_desc')
              end
            end
           end
        when :metrics
          metricsopts = etc[0]

          if opts.include?('bugs')
            opts['bugs'].each do |bug|
              if bug.include?('bug_status')
                bug['status'] = bug['bug_status']
                bug.delete('bug_status')
              end
              if bug.include?('bug_id')
                bug['id'] = bug['bug_id']
                bug.delete('bug_id')
              end
              if bug.include?('bug_severity')
                bug['severity'] = bug['bug_severity']
                bug.delete('bug_severity')
              end
              if bug.include?('short_desc')
                bug['summary'] = bug['short_desc']
                bug.delete('short_desc')
              end
            end
          end
       end
      end # def posthook
    end # class RedHat
  end # module Plugin
end # module Bugzilla
