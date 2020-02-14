# frozen_string_literal: true

# product.rb
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
  # === Bugzilla::Product
  #
  # Bugzilla::Product class is to access
  # the Bugzilla::WebService::Product API that allows you to
  # list the available Products and get information about them.
  #

  class Product < APITemplate
    # rdoc
    #
    # ==== Bugzilla::Product#selectable_products
    #
    # Returns Hash table for the products information that the user
    # can search on. the Hash key is the product name and containing
    # a Hash table which contains id, name, description,
    # is_active, default_milestone, has_uncomfirmed, classification,
    # components, versions and milestones. please see
    # http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Product.html#get
    # for more details.
    #

    def selectable_products
      ids = get_selectable_products
      Hash[*get(ids)['products'].map { |x| [x['name'], x] }.flatten]
    end # def selectable_products

    # rdoc
    #
    # ==== Bugzilla::Product#enterable_products
    #
    # Returns Hash table for the products information that the user
    # can enter bugs against. the Hash key is the product name and
    # containing a Hash table which contains id, name, description,
    # is_active, default_milestone, has_uncomfirmed, classification,
    # components, versions and milestones. please see
    # http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Product.html#get
    # for more details.
    #

    def enterable_products
      ids = get_enterable_products
      Hash[*get(ids)['products'].map { |x| [x['name'], x] }.flatten]
    end # def enterable_products

    # rdoc
    #
    # ==== Bugzilla::Product#accessible_products
    #
    # Returns Hash table for the products information that the user
    # can search or enter bugs against. the Hash key is the product
    # name and containing a Hash table which contains id, name, description,
    # is_active, default_milestone, has_uncomfirmed, classification,
    # components, versions and milestones. please see
    # http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Product.html#get
    # for more details.
    #

    def accessible_products
      ids = get_accessible_products
      Hash[*get(ids)['products'].map { |x| [x['name'], x] }.flatten]
    end # def accessible_products

    # rdoc
    #
    # ==== Bugzilla::Product#get_selectable_products
    #
    # Raw Bugzilla API to obtain the products that the user can
    # search on.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Product.html
    #

    # rdoc
    #
    # ==== Bugzilla::Product#get_enterable_products
    #
    # Raw Bugzilla API to obtain the products that the user can
    # enter bugs against.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Product.html
    #

    # rdoc
    #
    # ==== Bugzilla::Product#get_accessible_products
    #
    # Raw Bugzilla API to obtain the products that the user can
    # search or enter bugs against.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Product.html
    #

    # rdoc
    #
    # ==== Bugzilla::Product#get(params)
    #
    # Raw Bugzilla API to obtain a list of information about the products
    # passed to it.
    #
    # See http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Product.html
    #

    protected

    def _get_selectable_products(cmd, *_args)
      @iface.call(cmd)
    end # def _get_selectable_products

    def _get_enterable_products(cmd, *_args)
      @iface.call(cmd)
    end # def _get_entrable_products

    def _get_accessible_products(cmd, *_args)
      @iface.call(cmd)
    end # def _get_accessible_products

    def _get(cmd, ids, *_args)
      # This is still in experimental and apparently the behavior was changed since 4.2.
      # We don't keep the backward-compatibility and just require the proper version here.
      requires_version(cmd, 4.2)

      params = {}

      if ids.is_a?(Hash)
        unless ids.include?('ids') || ids.include?('names')
          raise ArgumentError, format('Invalid parameter: %s', ids.inspect)
        end

        params[:ids] = ids['ids'] || ids['names']
      elsif ids.is_a?(Array)
        r = ids.map { |x| x.is_a?(Integer) ? x : nil }.compact
        if r.length != ids.length
          params[:names] = ids
        else
          params[:ids] = ids
        end
      else
        if ids.is_a?(Integer)
          params[:ids] = [ids]
        else
          params[:names] = [ids]
        end
      end

      @iface.call(cmd, params)
    end # def _get

    def __create(cmd, *args)
      # FIXME
    end # def _create

    def __update(cmd, *_args)
      requires_version(cmd, 4.4)

      # FIXME
    end # def _update
  end # class Product
end # module Bugzilla
