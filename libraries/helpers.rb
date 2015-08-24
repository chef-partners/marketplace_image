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

module MarketplaceImageCookbook
  module Helpers
    def install_marketplace
      chef_ingredient 'chef-marketplace' do
        version new_resource.marketplace_version
        config marketplace_config
        action :upgrade
      end

      ingredient_config 'chef-marketplace' do
        notifies :reconfigure, 'chef_ingredient[chef-marketplace]'
      end
    end

    def install_server
      include_recipe 'yum-centos::default'

      chef_ingredient 'chef-server' do
        config server_config
        version new_resource.server_version
        action :upgrade
      end

      ingredient_config 'chef-server'

      chef_ingredient 'reporting' do
        config new_resource.reporting_config
        version new_resource.reporting_version
        action :upgrade
      end

      ingredient_config 'reporting'

      chef_ingredient 'manage' do
        config manage_config
        version new_resource.manage_version
        action :upgrade
      end

      ingredient_config 'manage'

      chef_ingredient 'analytics' do
        action :uninstall
      end
    end

    def install_analytics
      include_recipe 'yum-centos::default'

      chef_ingredient 'analytics' do
        config new_resource.analytics_config
        version new_resource.analytics_version
        action :install
      end

      ingredient_config 'analytics'

      chef_ingredient 'chef-server' do
        action :uninstall
      end

      chef_ingredient 'reporting' do
        action :uninstall
      end

      chef_ingredient 'manage' do
        action :uninstall
      end
    end

    def uninstall_server
      chef_ingredient 'chef-server' do
        action :uninstall
      end

      chef_ingredient 'reporting' do
        action :uninstall
      end

      chef_ingredient 'manage' do
        action :uninstall
      end
    end

    def uninstall_marketplace
      chef_ingredient 'chef-marketplace' do
        action :uninstall
      end
    end

    def uninstall_analytics
      chef_ingredient 'analytics' do
        action :uninstall
      end
    end

    def marketplace_config
      config = []
      config << "role '#{new_resource.role}'"
      config << "platform '#{new_resource.platform}'"
      config << "user '#{new_resource.default_user}'"
      config << "support['email'] = '#{new_resource.support_email}'"
      config << "documentation['url'] = '#{new_resource.doc_url}'"
      config << "reporting['cron']['enabled'] = '#{new_resource.reporting_cron}'"
      config << "publishing['enabled'] = #{new_resource.publish}"
      config << "diasable_outboud_traffic '#{new_resource.disable_outbound_traffic}'"
      config << new_resource.marketplace_config
      config.join("\n")
    end

    def server_config
      config = []
      config << "topology 'standalone'"
      config << "license['nodes'] = #{new_resource.license_count}"
      config << new_resource.server_config
      config.join("\n")
    end

    def manage_config
      config = []
      config << 'disable_sign_up true'
      config << new_resource.manage_config
      config.join("\n")
    end
  end
end
