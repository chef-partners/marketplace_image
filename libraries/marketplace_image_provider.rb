#
# Author:: Partner Engineering <partnereng@chef.io>
# Copyright (c) 2015, Chef Software, Inc. <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative './helpers'

class Chef
  class Provider
    class MarketplaceImage < Chef::Provider::LWRPBase
      provides :marketplace_image

      include MarketplaceImageCookbook::Helpers

      require 'chef/dsl/include_recipe'
      include Chef::DSL::IncludeRecipe

      use_inline_resources

      def whyrun_supported?
        true
      end

      action :install do
        prepare_machine
        install_marketplace

        case new_resource.role
        when 'server' then install_server
        when 'aio' then install_aio
        when 'analytics' then install_analytics
        when 'compliance' then install_compliance
        end

        execute 'chef-marketplace-ctl prepare-for-publishing yes' do
          only_if { new_resource.publish }
        end
      end

      action :uninstall do
        uninstall_marketplace

        case new_resource.role
        when 'server' then uninstall_server
        when 'aio' then uninstall_aio
        when 'analytics' then uninstall_analytics
        end
      end
    end
  end
end
