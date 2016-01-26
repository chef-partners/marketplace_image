#
# Cookbook Name:: marketplace_image
# Recipe:: aws_publisher
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

Chef::Config['chef_provisioning'] ||= Mash.new
Chef::Config['chef_provisioning']['machine_max_wait_time'] = 240
Chef::Config['chef_provisioning']['image_max_wait_time'] = 500

time = Time.now.strftime('%Y-%m-%d')
marketplace = node['marketplace_image']['marketplace']
product = node['marketplace_image']['product']
role = product.split('_').last
license_type = product =~ /flexible/ ? 'flexible' : 'fixed'
disable_outbound_traffic = marketplace =~ /ic/ ? true : false
ami_id = node['marketplace_image']['aws'][marketplace][product]['ami']
free_node_count = license_type == 'flexible' && product =~ /aio|server/ ? 5 : 0

# Add a unique name to each product
aws_images = node['marketplace_image']['aws'][marketplace][product]['products'].to_a.each_with_object([]) do |item, memo|
  item['name'] = "chef_#{role}_#{marketplace}"
  item['name'] << "_#{item['node_count']}" if license_type == 'fixed'
  item['name'] << '_flexible' if license_type == 'flexible'
  item['name'] << "_#{time}"
  memo << item
end

# Create the images
aws_images.each do |image|
  marketplace_ami image['name'] do
    source_image_id ami_id
    instance_type   'm4.xlarge'
    ssh_keyname     'marketplace_builder'
    ssh_username    'ec2-user'
    audit           false
    machine_options(
      convergence_options: {
        chef_version: '12.6.0',
        chef_client_timeout: 7200
      }
    )

    recipe    'marketplace_image::_publisher'
    attribute %w(marketplace_image role), role
    attribute %w(marketplace_image platform), 'aws'
    attribute %w(marketplace_image publish), true
    attribute %w(marketplace_image license_count), image['node_count']
    attribute %w(marketplace_image product_code), image['product_code']
    attribute %w(marketplace_image license_type), license_type
    attribute %w(marketplace_image free_node_count), free_node_count
    attribute %w(marketplace_image disable_outbound_traffic), disable_outbound_traffic
    attribute %w(marketplace_image doc_url), node['marketplace_image']['aws'][role]['doc_url']
  end
end

# Build manifest
manifest = proc do
  node.run_state['marketplace_amis'].each_with_object([]) do |image, memo|
    item = {}
    # AWS objects in the AWS SDK are unreliable, only add data if it exists
    item['name'] = image.name if image.respond_to?(:name)
    item['id'] = image.image_id if image.respond_to?(:image_id)
    item['created_at'] = image.creation_date if image.respond_to?(:creation_date)
    item['product_codes'] = image.product_codes if image.respond_to?(:product_codes)
    memo << item
  end
end

# Write manifest
file File.expand_path(File.join('~', "#{role}_#{marketplace}_amis.json")) do
  content lazy { Chef::JSONCompat.to_json_pretty(manifest.call) }
  action :create
end

# MANUAL STEPS
#
# Run the security scanner ( the api hasn't been released yet )
#
# Convert the marketplace_amis.json into Marketplace xlsx document
#
# Submit to marketplace
