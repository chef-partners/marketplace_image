#
# Author:: Partner Engineering <partnereng@chef.io>
# Copyright (c) 2016, Chef Software, Inc. <legal@chef.io>
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
    def marketplace_products
      aws_products + azure_products + gce_products
    end

    def enabled_products
      enabled_aws_products + enabled_azure_products + enabled_gce_products
    end

    def enabled_builders
      enabled_products.map { |p| p['name'] }
    end

    def enabled_image_names
      {
        'aws'   => enabled_aws_image_names,
        'azure' => enabled_azure_image_names,
        'gce'   => enabled_gce_image_names
      }
    end

    def aws_products
      node['marketplace_image']['aws']['public']['aio']['products'] +
        node['marketplace_image']['aws']['public']['compliance']['products'] +
        node['marketplace_image']['aws']['ic']['aio']['products'] +
        node['marketplace_image']['aws']['ic']['compliance']['products'] +
        [
          node['marketplace_image']['aws']['public']['aio']['fcp'],
          node['marketplace_image']['aws']['public']['compliance']['fcp']
        ]
    end

    def enabled_aws_builders
      enabled_aws_products.map { |p| p['name'] }
    end

    def aws_builders
      aws_products.map { |p| p['name'] }
    end

    def enabled_aws_products
      products = []
      products += node['marketplace_image']['aws']['public']['aio']['products'] if
        node['marketplace_image']['aws']['public']['aio']['enabled']
      products += node['marketplace_image']['aws']['public']['compliance']['products'] if
        node['marketplace_image']['aws']['public']['compliance']['enabled']
      products += node['marketplace_image']['aws']['ic']['aio']['products'] if
        node['marketplace_image']['aws']['ic']['aio']['enabled']
      products += node['marketplace_image']['aws']['ic']['compliance']['products'] if
        node['marketplace_image']['aws']['ic']['compliance']['enabled']
      products << node['marketplace_image']['aws']['public']['aio']['fcp'] if
        node['marketplace_image']['aws']['public']['aio']['fcp_enabled']
      products << node['marketplace_image']['aws']['public']['compliance']['fcp'] if
        node['marketplace_image']['aws']['public']['compliance']['fcp_enabled']
      products
    end

    def enabled_aws_image_names
      enabled_aws_products.map { |p| p['builder_options']['ami_name'] }
    end

    def azure_products
      node['marketplace_image']['azure']['aio']['products'] +
        node['marketplace_image']['azure']['compliance']['products']
    end

    def enabled_azure_products
      products = []
      products += node['marketplace_image']['azure']['aio']['products'] if
        node['marketplace_image']['azure']['aio']['enabled']
      products += node['marketplace_image']['azure']['compliance']['products'] if
        node['marketplace_image']['azure']['compliance']['enabled']
      products
    end

    def enabled_azure_image_names
      enabled_azure_products.map { |p| p['builder_options']['user_image_label'] }
    end

    def enabled_azure_builders
      enabled_azure_products.map { |p| p['name'] }
    end

    def azure_builders
      azure_products.map { |p| p['name'] }
    end

    def gce_products
      node['marketplace_image']['gce']['aio']['products'] +
        node['marketplace_image']['gce']['compliance']['products']
    end

    def enabled_gce_products
      products = []
      products += node['marketplace_image']['gce']['aio']['products'] if
        node['marketplace_image']['gce']['aio']['enabled']
      products += node['marketplace_image']['gce']['compliance']['products'] if
        node['marketplace_image']['gce']['compliance']['enabled']
      products
    end

    def enabled_gce_image_names
      enabled_gce_products.map { |p| p['builder_options']['image_name'] }
    end

    def gce_builders
      gce_products.map { |p| p['name'] }
    end

    def enabled_gce_builders
      enabled_gce_products.map { |p| p['name'] }
    end
  end
end

Chef::Recipe.send(:include, MarketplaceImageCookbook::Helpers)
Chef::Provider.send(:include, MarketplaceImageCookbook::Helpers)
Chef::Resource.send(:include, MarketplaceImageCookbook::Helpers)
Chef::ResourceDefinition.send(:include, MarketplaceImageCookbook::Helpers)
