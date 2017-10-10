# frozen_string_literal: true
cred_dir = ::File.expand_path(::File.join('~', '.aws'))
credential_file = ::File.join(cred_dir, 'credentials')

TIMESTAMP = Time.now.strftime('%Y_%m_%d_%H_%M_%S').freeze
INVALID_AMI_NAME_CHARACTERS = /[^\w\(\)\.\-\/]/

def normalize_name(name)
  # Append timestamp
  # Remove invalid characters
  # Ensure it's 128 characters or less
  "#{name}_#{TIMESTAMP}".gsub(INVALID_AMI_NAME_CHARACTERS, '').strip[0..127]
end

default['marketplace_image']['aws']['cred_dir'] = cred_dir
default['marketplace_image']['aws']['credential_file'] = credential_file

default['marketplace_image']['aws']['automate']['source_ami'] = 'ami-65ca3873'

default['marketplace_image']['aws']['public']['automate']['enabled'] = false

# NOTE: Currently we don't have product codes for Automate in the IC Marketplace.
# Until we get codes and add them into the Automate billing module we'll just
# have legacy AIO products, of which we are no longer creating.
default['marketplace_image']['aws']['ic']['automate']['enabled'] = false

default_marketplace_config = {
  'role' => 'automate',
  'platform' => 'aws',
  'user' => 'ec2-user',
  'support_email' => 'aws@chef.io',
  'sales_email' => 'awesome@chef.io',
  'reporting_cron_enabled' => false,
  'doc_url' => 'https://docs.chef.io/aws_marketplace.html',
  'disable_outbound_traffic' => false,
  'license_type' => 'flexible',
  'free_node_count' => 5,
}

aws_builder_config = {
  'type' => 'amazon-ebs',
  'region' => 'us-east-1',
  'source_ami' => node['marketplace_image']['aws']['automate']['source_ami'],
  'instance_type' => 'm4.xlarge',
  'ssh_username' => 'ec2-user',
  'ssh_pty' => 'true',
  'ami_name' => 'amazon',
}

default['marketplace_image']['aws']['public']['automate'] =
  {
    'name' => 'aws_public_automate',
    'builder_options' => aws_builder_config.merge(
      'ami_product_codes' => ['ed3lb0p2oc2ot3v9v72ku1pdt'],
      'ami_name' => normalize_name('public_automate')
    ),
    'marketplace_config_options' => default_marketplace_config.merge(
      'license_type' => 'flexible',
      'free_node_count' => 10,
      'product_code' => 'ed3lb0p2oc2ot3v9v72ku1pdt'
    ),
  }
