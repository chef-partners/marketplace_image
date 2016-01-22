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
required_keys = %w(credentials_file chef_server validator_name validator_file ssh_username)
missing_keys = required_keys.each_with_object([]) do |item, memo|
  memo << item unless node['gce'].key?(item)
end
raise "The following parameters are missing from your gce_config.json: #{missing_keys.join(', ')}" unless missing_keys.empty?

time = Time.now.strftime('%Y%m%d')
marketplace = node['marketplace_image']['marketplace']
product = node['marketplace_image']['product']
role = product.split('_').last
license_type = product =~ /flexible/ ? 'flexible' : 'fixed'
image_id = node['marketplace_image']['gce'][marketplace][product]['image_id']

# Add a unique name to each product
gce_images = node['marketplace_image']['gce'][marketplace][product]['products'].to_a.each_with_object([]) do |item, memo|
  item['name'] = "chef-#{role}-#{marketplace}"
  item['name'] << "-#{item['node_count']}" if license_type == 'fixed'
  item['name'] << "-#{time}"
  memo << item
end

# Create the images
gce_images.each do |image|
  marketplace_image_gce image['name'] do
    snapshot             true
    destroy_after        true
    gce_credentials_file node['gce']['credentials_file']
    project              'chef-partners-test'
    chef_server_url      node['gce']['chef_server']
    validator_name       node['gce']['validator_name']
    validator_key_file   node['gce']['validator_file']
    instance_type        'n1-standard-4'
    source_image_id      image_id
    ssh_username         node['gce']['ssh_username']
    ssh_key_file         node['gce']['ssh_key_file'] if node['gce']['ssh_key_file']
    marketplace_role     role
    license_type         license_type
    license_count        image['node_count']
    support_email        node['marketplace_image']['gce'][role]['support_email']
    doc_url              node['marketplace_image']['gce'][role]['doc_url']
  end
end

# Build manifest
#manifest = proc do
#  node.run_state['marketplace_gce_images'].each_with_object([]) do |image, memo|
#    memo << item
#  end
#end

# Write manifest
#file File.expand_path(File.join('~', "gce_#{role}_#{marketplace}_images.json")) do
#  content lazy { Chef::JSONCompat.to_json_pretty(manifest.call) }
#  action :create
#end
