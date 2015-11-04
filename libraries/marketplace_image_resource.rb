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

class Chef
  class Resource
    class MarketplaceImage < Chef::Resource::LWRPBase
      resource_name :marketplace_image

      actions :install, :uninstall
      default_action :install
      state_attrs :installed

      attribute :installed, kind_of: [TrueClass, FalseClass, NilClass], default: false

      # Marketplace
      attribute :role, kind_of: String, name_attribute: true
      attribute :platform, kind_of: String, default: nil
      attribute :default_user, kind_of: String, default: nil
      attribute :support_email, kind_of: String, default: nil
      attribute :product_code, kind_of: String, default: nil
      attribute :doc_url, kind_of: String, default: nil
      attribute :marketplace_config, kind_of: [String, NilClass], default: nil
      attribute :marketplace_version, kind_of: [String, NilClass], default: 'latest'
      attribute :reporting_cron, kind_of: [TrueClass, FalseClass], default: true
      attribute :publish, kind_of: [TrueClass, FalseClass], default: true
      attribute :disable_outbound_traffic, kind_of: [TrueClass, FalseClass], default: false

      # Chef Server
      attribute :license_count, kind_of: [String, Integer], default: 5
      attribute :server_config, kind_of: [String, NilClass], default: nil
      attribute :server_version, kind_of: [String, NilClass], default: 'latest'

      # Manage
      attribute :manage_config, kind_of: [String, NilClass], default: nil
      attribute :manage_version, kind_of: [String, NilClass], default: 'latest'

      # Reporting
      attribute :reporting_config, kind_of: [String, NilClass], default: nil
      attribute :reporting_version, kind_of: [String, NilClass], default: 'latest'

      # Analytics
      attribute :analytics_config, kind_of: [String, NilClass], default: nil
      attribute :analytics_version, kind_of: [String, NilClass], default: 'latest'

      # Compliance
      attribute :compliance_config, kind_of: [String, NilClass], default: nil
      attribute :compliance_version, kind_of: [String, NilClass], default: 'latest'
    end
  end
end
