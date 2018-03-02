# bug.rb
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

require 'bugzilla/api_template'

module Bugzilla
  # rdoc
  #
  # === Bugzilla::Bug
  #
  # Bugzilla::Bug class is to access
  # the Bugzilla::WebService::Bug API that allows you to file
  # a new bug in Bugzilla or get information about bugs that
  # have already been filed.
  #

  class Bug < APITemplate
    FIELDS_SUMMARY = %w[id product component status severity summary].freeze
    FIELDS_DETAILS = FIELDS_SUMMARY + %w[assigned_to internals priority resolution]
    FIELDS_ALL = %w[alias assigned_to blocks cc classification
                    component creation_time creator deadline
                    depends_on dupe_of estimated_time groups
                    id is_cc_accessible is_confirmed is_open
                    is_creator_accessible keywords last_change_time
                    op_sys platform priority product qa_contact
                    remaining_time resolution see_also severity
                    status summary target_milestone update_token
                    url version whiteboard
                    external_bugs internals].freeze

    # rdoc
    #
    # ==== Bugzilla::Bug#get_bugs(bugs, fields = Bugzilla::Bug::FIELDS_SUMMARY)
    #
    # Get the _bugs_ information from Bugzilla. either of String
    # or Numeric or Array would be acceptable for _bugs_. you can
    # specify the fields you want to look up with _fields_.
    #
    # FWIW this name conflicts to Bugzilla API but this isn's a
    # primitive method since get_bugs method in WebService API is
    # actually deprecated.
    #

    def get_bugs(bugs, fields = FIELDS_SUMMARY)
      params = {}

      params['ids'] = case bugs
      when Array
        bugs
      when Integer || String
        [bugs]
      else
        raise ArgumentError, format('Unknown type of arguments: %s', bugs.class)
      end

      unless fields.nil?
        unless (fields - FIELDS_ALL).empty?
          raise ArgumentError, format('Invalid fields: %s', (FIELDS_ALL - fields).join(' '))
        end
        params['include_fields'] = fields
      end

      result = get(params)

      if fields.nil? || fields == FIELDS_ALL
        get_comments(bugs).each do |id, c|
          result['bugs'].each do |r|
            next unless r['id'].to_s == id.to_s
            r['comments'] = c['comments']
            r['comments'] = [] if r['comments'].nil?
            break
          end
        end
      end

      # 'bugs' is only in interests.
      # XXX: need to deal with 'faults' ?
      result['bugs']
    end # def get_bugs

    # rdoc
    #
    # ==== Bugzilla::Bug#get_comments(bugs)
    #

    def get_comments(bugs)

      params = {}

      # TODO
      # this construction should be refactored to a method
      params['ids'] = case bugs
      when Array
        bugs
      when Integer || String
        [bugs]
      else
        raise ArgumentError, format('Unknown type of arguments: %s', bugs.class)
      end

      result = comments(params)

      # not supporting comment_ids. so drop "comments".
      ret = result['bugs']
      # creation_time was added in Bugzilla 4.4. copy the 'time' value to creation_time if not available for compatibility.
      unless check_version(4.4)[0]
        ret.each do |_id, o|
          o['comments'].each do |c|
            c['creation_time'] = c['time'] unless c.include?('creation_time')
          end
        end
      end

      ret
    end # def get_comments

    # rdoc
    #
    # ==== Bugzilla::Bug#fields(params)
    #
    # Raw Bugzilla API to obtain the information about valid bug
    # fields, including the lists of legal values for each field.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Bug.html
    #

    # rdoc
    #
    # ==== Bugzilla::Bug#legal_values(params)
    #
    # Raw Bugzilla API to obtain the information what values are
    # allowed for a particular field.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Bug.html
    #

    # rdoc
    #
    # ==== Bugzilla::Bug#attachments(params)
    #
    # Raw Bugzilla API to obtain the information about
    # attachments, given a list of bugs and/or attachment ids.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Bug.html
    #

    # rdoc
    #
    # ==== Bugzilla::Bug#comments(params)
    #
    # Raw Bugzilla API to obtain the information about comments,
    # given a list of bugs and/or comment ids.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Bug.html
    #

    # rdoc
    #
    # ==== Bugzilla::Bug#get(params)
    #
    # Raw Bugzilla API to obtain the information about particular
    # bugs in the database.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Bug.html
    #

    # rdoc
    #
    # ==== Bugzilla::Bug#history(params)
    #
    # Raw Bugzilla API to obtain the history of changes for
    # particular bugs in the database.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Bug.html
    #

    # rdoc
    #
    # ==== Bugzilla::Bug#search(params)
    #
    # Raw Bugzilla API to search for bugs based on particular
    # criteria.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Bug.html
    #

    # rdoc
    #
    # ==== Bugzilla::Bug#create(params)
    #
    # Raw Bugzilla API to create a new bug in Bugzilla.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Bug.html
    #

    protected

    def _fields(cmd, *args)
      requires_version(cmd, 3.6)
      params = {}
      a = args[0]
      case a
      when Array
        is = a.map { |x| x.is_a?(Integer) }.uniq
        params['ids'] = a if is.size == 1 && is[0]
        ss = a.map { |x| x.is_a?(String) }.uniq
        params['names'] = a if ss.size == 1 && ss[0]
      when Hash
        params = a
      when Integer
        params['ids'] = [a]
      when String
        params['names'] = [a]
      else
        raise ArgumentError, 'Invalid parameters'
      end
      @iface.call(cmd, params)
    end # def _fields

    def _legal_values(cmd, *args)
      raise ArgumentError, 'Invalid parameters' unless args[0].is_a?(Hash)

      @iface.call(cmd, args[0])
    end # def _legal_values

    def _attachments(cmd, *args)
      requires_version(cmd, 3.6)

      raise ArgumentError, 'Invalid parameters' unless args[0].is_a?(Hash)

      @iface.call(cmd, args[0])
    end # def _attachments

    def _comments(cmd, *args)
      requires_version(cmd, 3.4)

      raise ArgumentError, 'Invalid parameters' unless args[0].is_a?(Hash)

      @iface.call(cmd, args[0])
    end # def _comments

    def _get(cmd, *args)
      params = {}

      a = args[0]

      case a
      when Hash
        params = a
      when Array
        params['ids'] = a
      when Integer || String
        params['ids'] = [a]
      else
        raise ArgumentError, 'Invalid parameters'
      end

      params['permissive'] = true if check_version(3.4)[0]

      @iface.call(cmd, params)
    end # def _get

    def _history(cmd, *args)
      requires_version(cmd, 3.4)

      params = {}
      a = args[0]
      case a
      when Hash
        params = a
      when Array
        params['ids'] = a
      when Integer || String
        params['ids'] = [a]
      else
        raise ArgumentError, 'Invalid parameters'
      end

      @iface.call(cmd, params)
    end # def _history

    def _search(cmd, *args)
      requires_version(cmd, 3.4)

      raise ArgumentError, 'Invalid parameters' unless args[0].is_a?(Hash)

      @iface.call(cmd, args[0])
    end # def _search

    def _create(cmd, *args)
      raise ArgumentError, 'Invalid parameters' unless args[0].is_a?(Hash)

      required_fields = %i[product component summary version]
      defaulted_fields = %i[description op_sys platform priority severity]

      res = check_version('3.0.4')
      required_fields.push(*defaulted_fields) unless res[0]
      required_fields.each do |f|
        raise ArgumentError, format("Required fields isn't given: %s", f) unless args[0].include?(f)
      end
      res = check_version(4.0)
      if res[0]
        if args[0].include?('commentprivacy')
          args[0]['comment_is_private'] = args[0]['commentprivacy']
          args[0].delete('commentprivacy')
        end
      else
        raise ArgumentError, "groups field isn't available in this bugzilla" if args[0].include?('groups')
        raise ArgumentError, "comment_is_private field isn't available in this bugzilla" if args[0].include?('comment_is_private')
      end

      @iface.call(cmd, args[0])
    end # def _create

    def __add_attachment(cmd, *_args)
      requires_version(cmd, 4.0)
      # FIXME
    end # def _add_attachment

    def __add_comment(cmd, *_args)
      requires_version(cmd, 3.2)
      # FIXME
    end # def _add_comment

    def __update(cmd, *_args)
      requires_version(cmd, 4.0)
      # FIXME
    end # def _update

    def __update_see_also(cmd, *_args)
      requires_version(cmd, 3.4)
      # FIXME
    end # def _update_see_also

    def __update_tags(cmd, *_args)
      requires_version(cmd, 4.4)
      # FIXME
    end # def _update_tags
  end # class Bug
end # module Bugzilla
