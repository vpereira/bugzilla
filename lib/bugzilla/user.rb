# user.rb
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

require 'yaml'
require 'bugzilla/api_template'

module Bugzilla
  # rdoc
  #
  # === Bugzilla::User
  #
  # Bugzilla::User class is to access the
  # Bugzilla::WebService::User API that allows you to create
  # User Accounts and log in/out using an existing account.
  #

  class User < APITemplate
    # rdoc
    #
    # ==== Bugzilla::User#session(user, password)
    #
    # Keeps the bugzilla session during doing something in the block.
    #

    def session(user, password)
      key, fname = authentication_method

      # TODO
      # make those variables available
      host = @iface.instance_variable_get(:@xmlrpc).instance_variable_get(:@host)

      conf = load_authentication_token(fname)

      val = conf.fetch(host, nil)

      if !val.nil?
        if key == :token
          @iface.token = val
        else
          @iface.cookie = val
        end
        yield
      elsif user.nil? || password.nil?
        yield
        return
      else
        login('login' => user, 'password' => password, 'remember' => true)
        yield
      end

      conf[host] = @iface.send(key) if %i[token cookie].include? key

      save_authentication_token(fname, conf)
      key
    end # def session

    # rdoc
    #
    # ==== Bugzilla::User#get_userinfo(params)
    #

    def get_userinfo(user)
      p = {}
      ids = []
      names = []

      if user.is_a?(Array)
        user.each do |u|
          names << u if u.is_a?(String)
          id << u if u.is_a?(Integer)
        end
      elsif user.is_a?(String)
        names << user
      elsif user.is_a?(Integer)
        ids << user
      else
        raise ArgumentError, format('Unknown type of arguments: %s', user.class)
      end

      result = get('ids' => ids, 'names' => names)

      result['users']
    end # def get_userinfo

    # rdoc
    #
    # ==== Bugzilla::User#login(params)
    #
    # Raw Bugzilla API to log into Bugzilla.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/User.html
    #

    # rdoc
    #
    # ==== Bugzilla::User#logout
    #
    # Raw Bugzilla API to log out the user.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/User.html
    #

    protected

    def load_authentication_token(fname)
      if File.exist?(fname) && File.lstat(fname).mode & 0o600 == 0o600
        YAML.safe_load(File.open(fname).read)
      else
        {}
      end
    end

    def save_authentication_token(fname, conf)
      File.open(fname, 'w') { |f| f.chmod(0o600); f.write(conf.to_yaml) }
    end

    def is_token_supported?
      check_version('4.4.3')[0] == true
    rescue StandardError
      false
    end

    # it returns an array with authentication type and the name of the storage
    def authentication_method
      # if version supported, use token, otherwise cookie
      if is_token_supported?
        [:token, File.join(ENV['HOME'], '.ruby-bugzilla-token.yml')]
      else
        [:cookie, File.join(ENV['HOME'], '.ruby-bugzilla-cookie.yml')]
      end
    end

    def _login(cmd, *args)
      raise ArgumentError, 'Invalid parameters' unless args[0].is_a?(Hash)

      res = @iface.call(cmd, args[0])
      @iface.token = res['token'] unless res['token'].nil?

      res
    end # def _login

    def _logout(cmd, *_args)
      @iface.call(cmd)
    end # def _logout

    def __offer_account_by_email(cmd, *args)
      # FIXME
    end # def _offer_account_by_email

    def __create(cmd, *args)
      # FIXME
    end # def _create

    def __update(cmd, *args)
      # FIXME
    end # def _update

    def _get(cmd, *args)
      raise ArgumentError, 'Invalid parameters' unless args[0].is_a?(Hash)

      requires_version(cmd, 3.4)
      res = @iface.call(cmd, args[0])
      # FIXME
    end # def _get
  end # class User
end # module Bugzilla
