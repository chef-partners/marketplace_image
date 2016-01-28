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
  module GceHelpers
    def gce_metadata_source(role)
      case role
      when 'aio', 'server'
        'gce_image_metadata_aio.json.erb'
      when 'compliance'
        'gce_image_metadata_compliance.json.erb'
      end
    end

    def gce_product_name(role)
      case role
      when 'aio', 'server'
        'Chef Server'
      when 'compliance'
        'Chef Compliance'
      else
        fail "Unknown role: #{role}"
      end
    end

    def gce_listing_name(role, license_count)
      "#{gce_product_name(role)} (#{license_count_text(role, license_count)} node license)"
    end

    def gce_listing_description(role, license_count)
      case role
      when 'aio', 'server'
        description = 'The Chef Server image helps you launch a Chef Server in minutes with 1-Click, hourly billing and support from Chef Software.  It comes preinstalled Chef Server, Analytics, Management Console, and Reporting'

        description += if license_count == 5
                         '.  This image is free of software charge and licensed for 5 nodes.'
                       else
                         " and is licensed for #{license_count} nodes."
                       end
      when 'compliance'
        description = 'The Chef Compliance server delivers true compliance to your infrastructure by scanning for risks and compliance issues with customizable reports and visualization, automated remediation, and continuous audit for applications and infrastructure. '
      end

      description
    end

    def license_count_text(role, license_count)
      return license_count unless %w(aio server).include?(role)

      if license_count == 5
        'Free 5'
      else
        license_count
      end
    end
  end
end

if defined?(Chef)
  Chef::Recipe.send(:include, MarketplaceImageCookbook::GceHelpers)
  Chef::Resource.send(:include, MarketplaceImageCookbook::GceHelpers)
end
