#
# Cookbook Name:: marketplace_image
# Recipe:: aws_server_publisher
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

version = run_context.cookbook_collection['marketplace_image'].metadata.version
time = Time.now.strftime('%Y-%m-%d')

# Add a unique name to each product
aws_products = node['marketplace_image']['aws']['server_products'].to_a.each_with_object([]) do |product, memo|
  product['image_name'] = "marketplace_server_#{product['node_count']}_#{version}_#{time}"
  memo << product
end

# Create the images
aws_products.each do |product|
  marketplace_ami product['image_name'] do
    source_image_id node['marketplace_image']['aws']['origin_ami']
    instance_type   'm4.xlarge'
    ssh_keyname     'marketplace_builder'
    ssh_username    'ec2-user'

    recipe    'marketplace_image::_publisher'
    attribute %w(marketplace_image role), 'server'
    attribute %w(marketplace_image platform), 'aws'
    attribute %w(marketplace_image publish), true
    attribute %w(marketplace_image license_count), product['node_count']
    attribute %w(marketplace_image product_code), product['product_code']
  end
end

# Write out an image manifest
file File.join(Dir.pwd, 'server_images.json') do
  content (lazy do
    Chef::JSONCompat.to_json_pretty(
      node.run_state['marketplace_amis'].map do |image|
        {
          name: image.name,
          id: image.image_id,
          created_at: image.creation_date,
          product_codes: image.product_codes
        }
      end
    )
  end)

  action :create
end

#
# ## MANUAL STEPS
#
# Run the security scanner ( the api hasn't been released yet )
#
# Convert the aws_images.json into Marketplace xlsx document
#
# Submit to marketplace
