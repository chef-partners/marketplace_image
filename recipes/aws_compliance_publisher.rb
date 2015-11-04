#
# Cookbook Name:: marketplace_image
# Recipe:: aws_compliance_publisher
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
aws_products = node['marketplace_image']['aws']['compliance']['products'].to_a.each_with_object([]) do |product, memo|
  product['image_name'] = "chef_compliance_#{product['node_count']}_#{version}_#{time}"
  memo << product
end

# Create the images
aws_products.each do |product|
  marketplace_ami product['image_name'] do
    source_image_id node['marketplace_image']['aws']['compliance']['origin_ami']
    instance_type   'm4.xlarge'
    ssh_keyname     'marketplace_builder'
    ssh_username    'ec2-user'
    audit           false

    recipe    'marketplace_image::_publisher'
    attribute %w(marketplace_image role), 'compliance'
    attribute %w(marketplace_image platform), 'aws'
    attribute %w(marketplace_image publish), true
    attribute %w(marketplace_image doc_url), node['marketplace_image']['aws']['compliance']['support_email']
    attribute %w(marketplace_image license_count), product['node_count']
    attribute %w(marketplace_image product_code), product['product_code']
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
file File.join(Dir.pwd, 'marketplace_amis.json') do
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
