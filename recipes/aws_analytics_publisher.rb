require 'chef/provisioning/aws_driver'
require 'chef/json_compat'

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
image_name = "marketplace_analytics_#{version}_#{time}"
node.run_state['image_name'] = image_name

machine_image image_name do
  recipe 'marketplace_image::_publisher'
  attribute %w(marketplace_image role), 'analytics'
  attribute %w(marketplace_image platform), 'aws'
end

ruby_block "copy #{image_name} to all regions" do
  block do
    aws_driver = run_context.chef_provisioning.current_driver
    chef_server = run_context.cheffish.current_chef_server
    node.run_state['analytics_amis'] = []
    image_name = node.run_state['image_name']

    aws_image = Chef::Resource::AwsImage.get_aws_object(
      image_name,
      run_context: run_context,
      driver: aws_driver,
      managed_entry_store: Chef::Provisioning.chef_managed_entry_store(chef_server)
    )

    AWS.regions.each do |region|
      # Skip us-east-1 because that's where our source AMI is
      next if region.name == 'us-east-1'

      # Copy the image to the new region
      res = region.ec2.client.copy_image(
        source_region: 'us-east-1',
        source_image_id: aws_image.id,
        name: image_name,
        description: "Copy of #{aws_image.id} to #{region.name}"
      )

      new_image = region.ec2.images.with_owner('self').find { |i| i.id == res[:image_id] }
      node.run_state['analytics_amis'] << new_image
    end

    # Wait until the AMIs are available
    loop do
      states = node.run_state['analytics_amis'].map(&:state)
      break if states.all? { |state| state == :available }
      puts "Waiting for images to become available.  Current image states: #{states}"
      sleep 10
    end

    node.run_state['analytics_amis'] = node.run_state['analytics_amis'].each_with_object([]) do |ami, memo|
      ami.public = true

      memo << {
        'ami_id' => ami.id,
        'image_name' => ami.name,
        'region' => ami.client.config.region
      }
    end
  end
end

file "#{Chef::Config[:chef_repo_path]}/analytics_images.json" do
  content lazy { Chef::JSONCompat.to_json_pretty(node.run_state['analytics_amis']) }
  action :create
end
