#
# Cookbook Name:: marketplace_image
# Recipe:: gce_publisher
#
# Copyright (C) 2015 Chef Software, Inc.
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

# ensure required info is in Chef::Config
required_keys = %w(credentials_file chef_server validation_client_name validation_key ssh_username)
missing_keys = required_keys.each_with_object([]) do |item, memo|
  memo << item unless node['gce'].key?(item)
end
fail "The following parameters are missing from your gce_config.json: #{missing_keys.join(', ')}" unless missing_keys.empty?

time = Time.now.strftime('%Y%m%d')
marketplace = node['marketplace_image']['marketplace']
product = node['marketplace_image']['product']
role = product.split('_').last
license_type = product =~ /flexible/ ? 'flexible' : 'fixed'
image_id = node['marketplace_image']['gce'][marketplace][product]['image_id']
gce_project = 'chef-partners-test'
gce_bucket = 'chef-partners-test-images'
release_version = node['marketplace_image']['release_version']

# Add a unique name to each product
gce_images = node['marketplace_image']['gce'][marketplace][product]['products'].to_a.each_with_object([]) do |item, memo|
  item['name'] = "chef-#{role}-#{marketplace}"
  item['name'] << "-#{item['node_count']}" if license_type == 'fixed'
  item['name'] << "-#{time}"
  memo << item
end

output_dir = File.expand_path(File.join('~', 'gce_image_metadata'))
directory output_dir do
  action :create
end

gce_images.each do |image|
  node_attributes = {
    'marketplace_image' => {
      'instance_name'     => image['name'],
      'role'              => role,
      'platform'          => 'gce',
      'license_count'     => image['node_count'],
      'license_type'      => license_type,
      'support_email'     => node['marketplace_image']['gce'][role]['support_email'],
      'doc_url'           => node['marketplace_image']['gce'][role]['doc_url'],
      'publishing_bucket' => gce_bucket,
      'publish'           => true
    }
  }

  marketplace_image_gce image['name'] do
    destroy_after          true
    gce_credentials_file   node['gce']['credentials_file']
    project                gce_project
    chef_server_url        node['gce']['chef_server']
    validation_client_name node['gce']['validation_client_name']
    validation_key         node['gce']['validation_key']
    instance_type          'n1-standard-4'
    source_image_id        image_id
    ssh_username           node['gce']['ssh_username']
    ssh_key_file           node['gce']['ssh_key_file'] if node['gce']['ssh_key_file']
    run_list               ['marketplace_gce::bootstrap', 'marketplace_image::_publisher', 'marketplace_gce::create_snapshot']
    node_attributes        node_attributes
  end

  template File.join(output_dir, "chef-#{role}-#{image['node_count']}-#{release_version}.json") do
    source gce_metadata_source(role)
    variables(
      listing_name: gce_listing_name(role, image['node_count']),
      image_name:   image['name'],
      description:  gce_listing_description(role, image['node_count']),
      version:      release_version
    )
    action :create
  end
end
