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

default['marketplace_image']['alibaba']['product_urls'] = {
  'marketplace' => 'http://chef-software.oss-cn-beijing.aliyuncs.com/chef-marketplace_0.2.5%2B20171003114422.git.4.cce18c9-1_amd64.deb',
  'automate' => 'http://chef-software.oss-cn-beijing.aliyuncs.com/automate_1.6.179-1_amd64.deb',
  'chef_server' => 'http://chef-software.oss-cn-beijing.aliyuncs.com/chef-server-core_12.16.9-1_amd64.deb',
}

default_marketplace_config = {
  'role' => 'automate',
  'platform' => 'alibaba',
  'user' => 'ubuntu',
  'support_email' => 'alibaba@chef.io',
  'sales_email' => 'awesome@chef.io',
  'reporting_cron_enabled' => false,
  'doc_url' => 'https://docs.chef.io/alibaba_marketplace.html',
  'disable_outbound_traffic' => false,
  'license_type' => 'fixed',
  'free_node_count' => 5,
}

alibaba_builder_config = {
  'type' => 'alicloud-ecs',
  'region' => 'cn-beijing',
  'image_name' => 'chef_automate_20171020_1',
  'source_image' => 'ubuntu_14_0405_64_20G_alibase_20170824.vhd',
  'ssh_username' => 'root',
  'instance_type' => 'ecs.n4.xlarge',
  'io_optimized' => 'true',
  'internet_charge_type' => 'PayByTraffic',
  'image_force_delete' => 'true',
}

default['marketplace_image']['alibaba']['automate'] = {
  'name' => 'alibaba_automate_BYOL',
  'builder_options' => alibaba_builder_config,
  'marketplace_config_options' => default_marketplace_config,
}
