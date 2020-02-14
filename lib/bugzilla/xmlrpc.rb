# frozen_string_literal: true

# xmlrpc.rb
# Copyright (C) 2010-2014 Red Hat, Inc.
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

require 'xmlrpc/client'

module Bugzilla
  # rdoc
  #
  # === Bugzilla::XMLRPC
  #

  class XMLRPC
    # rdoc
    #
    # ==== Bugzilla::XMLRPC#new(host, port = 443, path = '/xmlrpc.cgi', proxy_host = nil, proxy_port = nil)
    #
    def initialize(host, port: 443, path: '/xmlrpc.cgi', proxy_host: nil,
                   proxy_port: nil, timeout: 60, http_basic_auth_user: nil, http_basic_auth_pass: nil, debug: false)
      path ||= '/xmlrpc.cgi'
      use_ssl = port == 443
      @xmlrpc = ::XMLRPC::Client.new(host, path, port, proxy_host, proxy_port, http_basic_auth_user, http_basic_auth_pass, use_ssl, timeout)
      # workaround for https://bugs.ruby-lang.org/issues/8182
      @xmlrpc.http_header_extra = { 'accept-encoding' => 'identity' }
      @xmlrpc.http.set_debug_output($stdout) if debug
    end # def initialize

    def use_ssl?
      @xmlrpc.http.use_ssl?
    end

    # rdoc
    #
    # ==== Bugzilla::XMLRPC#call(cmd, params, user = nil, password = nil)
    #

    def call(cmd, params = {}, user = nil, password = nil)
      params = {} if params.nil?
      params['Bugzilla_login'] = user unless user.nil? || password.nil?
      params['Bugzilla_password'] = password unless user.nil? || password.nil?
      params['Bugzilla_token'] = @token unless @token.nil?
      @xmlrpc.call(cmd, params)
    end # def call

    # rdoc
    #
    # ==== Bugzilla::XMLRPC#cookie
    #

    def cookie
      @xmlrpc.cookie
    end # def cookie

    # rdoc
    #
    # ==== Bugzilla::XMLRPC#cookie=(val)
    #

    def cookie=(val)
      @xmlrpc.cookie = val
    end # def cookie=

    # rdoc
    #
    # ==== Bugzilla::XMLRPC#token
    #

    attr_reader :token # def token

    # rdoc
    #
    # ==== Bugzilla::XMLRPC#token=(val)
    #

    attr_writer :token # def token=
  end # class XMLRPC
end # module Bugzilla
