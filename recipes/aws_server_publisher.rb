require 'chef/provisioning/aws_driver'
require 'chef/json_compat'

# Set up AWS Driver
with_driver 'aws::us-east-1'

with_chef_server Chef::Config['chef_server_url']

with_machine_options(
  bootstrap_options: {
    image_id: node['marketplace_image']['aws']['origin_ami'],
    instance_type: 'm4.xlarge',
    availability_zone: 'us-east-1a',
    key_name: 'marketplace_builder',
    associate_public_ip_address: true
  },
  convergence_options: {
    chef_client_timeout: 7200,
    chef_verion: '12.3.0'
  },
  ssh_username: 'ec2-user'
)

version = run_context.cookbook_collection['marketplace_image'].metadata.version
time = Time.now.strftime('%Y-%m-%d')
node.run_state['aws_products'] = []

# Add a unique name to each product
aws_products = node['marketplace_image']['aws']['server_products'].to_a.each_with_object([]) do |product, memo|
  product['image_name'] = "marketplace_server_#{product['node_count']}_#{version}_#{time}"
  memo << product
end

# Create the images
aws_products.each do |product|
  machine_image product['image_name'] do
    recipe 'marketplace_image::_publisher'
    attribute %w(marketplace_image role), 'server'
    attribute %w(marketplace_image platform), 'aws'
    attribute %w(marketplace_image license_count), product['node_count']
    attribute %w(marketplace_image product_code), product['product_code']
  end

  ruby_block "share #{product['image_name']} with the AWS Marketplace account" do
    block do
      aws_driver = run_context.chef_provisioning.current_driver
      current_options = run_context.chef_provisioning.current_machine_options
      chef_server = run_context.cheffish.current_chef_server
      aws = Chef::Provisioning::AWSDriver::Driver.from_url(aws_driver, current_options)

      aws_image = Chef::Resource::AwsImage.get_aws_object(
        product['image_name'],
        run_context: run_context,
        driver: aws_driver,
        managed_entry_store: Chef::Provisioning.chef_managed_entry_store(chef_server)
      )

      # Find the snapshot that was used to create the AMI
      # Each AMI should only have a single snapshot but because we have to parse
      # the shapshot description we might get more than one. Share them all just in
      # case.
      image_snapshots = aws.ec2.snapshots.with_owner('self').select do |snap|
        snap.description =~ /#{aws_image.id}/
      end

      # Share the snapshots and image with the aws-marketplace account
      aws_image.permissions.add('679593333241')
      image_snapshots.each { |snap| snap.permissions.add('679593333241') }

      # Add our product to the run state
      product['ami_id'] = aws_image.id
      product['snapshots'] = image_snapshots.map(&:id)
      node.run_state['aws_products'] << product

      # FIXME: this API call currently fails with our product codes
      # Set the product ID
      # aws_image.add_product_codes(product['product_code'])
    end
  end
end

file "#{Chef::Config[:chef_repo_path]}/server_images.json" do
  content lazy { Chef::JSONCompat.to_json_pretty(node.run_state['aws_products']) }
  action :create
end

#
#
# ## MANUAL STEPS
#
# Run the security scanner ( the api hasn't been released yet )
#
#
# Convert the aws_images.json into Marketplace xlsx document
#
#
# Submit to marketplace
