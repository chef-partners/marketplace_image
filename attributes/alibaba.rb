# frozen_string_literal: true
cred_dir = ::File.expand_path(::File.join('~', '.alibaba'))
credential_file = ::File.join(cred_dir, 'credentials')

TIMESTAMP = Time.now.strftime('%Y_%m_%d_%H_%M_%S').freeze
INVALID_AMI_NAME_CHARACTERS = /[^\w\(\)\.\-\/]/

def normalize_name(name)
  # Append timestamp
  # Remove invalid characters
  # Ensure it's 128 characters or less
  "#{name}_#{TIMESTAMP}".gsub(INVALID_AMI_NAME_CHARACTERS, '').strip[0..127]
end

default['marketplace_image']['alibaba']['cred_dir'] = cred_dir
default['marketplace_image']['alibaba']['credential_file'] = credential_file

default['marketplace_image']['alibaba']['public']['compliance']['enabled'] = false
default['marketplace_image']['alibaba']['public']['automate']['enabled'] = false

default['marketplace_image']['alibaba']['marketplace']['url'] = '
http://chef-software.oss-cn-beijing.aliyuncs.com/chef-marketplace_0.2.5%2B20170906073057-1_amd64.deb'

default_marketplace_config = {
  'role' => 'automate',
  'platform' => 'alibaba',
  'user' => 'root',
  'support_email' => 'aws@chef.io',
  'sales_email' => 'awesome@chef.io',
  'reporting_cron_enabled' => false,
  'doc_url' => 'https://docs.chef.io/aws_marketplace.html',
  'disable_outbound_traffic' => false,
  'license_type' => 'flexible',
  'free_node_count' => 5,
}

alibaba_builder_config = {
  'type' => 'alicloud-ecs',
  'region' => 'cn-beijing',
  'image_name' => 'chef_automate',
  'source_image' => 'ubuntu_14_0405_64_40G_alibase_20170711.vhd',
  'ssh_username' => 'root',
  'instance_type' => 'ecs.n2.medium',
  'io_optimized' => 'true',
  'internet_charge_type' => 'PayByTraffic',
  'image_force_delete' => 'true',
}

default['marketplace_image']['alibaba']['automate'] = {
  'name' => 'alibaba_automate_BYOL',
  'builder_options' => alibaba_builder_config,
  'marketplace_config_options' => default_marketplace_config,
}
