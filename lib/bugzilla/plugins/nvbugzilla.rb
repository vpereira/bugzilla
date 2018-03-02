# nvbugzilla.rb
# Copyright (C) 2014 Novell, Inc.
#
# Authors:
#  Victor Pereira  <vpereira@suse.com>
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
    class Novell < ::Bugzilla::Plugin::Template
      def initialize
        super
        @hostname = 'bugzilla.novell.com'
      end # def initialize

      def parserhook(*args)
        super
      end # def parserhook

      def prehook(*args)
        super
      end # def prehook

      def posthook(*args)
        super
      end # def posthook
    end # class Novell
  end # module Plugin
end # module Bugzilla
