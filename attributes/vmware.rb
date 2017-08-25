# frozen_string_literal: true
default['marketplace_image']['vmware']['aio']['enabled'] = false
default['marketplace_image']['vmware']['compliance']['enabled'] = false

cred_dir = ::File.expand_path(::File.join('~', '.vmware'))
account_file = ::File.join(cred_dir, 'account.json')

default['marketplace_image']['vmware']['cred_dir'] = cred_dir
default['marketplace_image']['vmware']['account_file'] = account_file

default_marketplace_config = {
  'role' => 'aio',
  'platform' => 'vmware',
  'support_email' => 'cloud-marketplaces@chef.io',
  'reporting_cron_enabled' => true,
  'doc_url' => 'https://docs.chef.io/google_marketplace.html',
  'disable_outbound_traffic' => false,
  'license_count' => 25,
  'license_type' => 'fixed',
  'free_node_count' => 5,
}

vmware_builder_config = {
  'type' => 'vmware',
  'account_file' => node['marketplace_image']['vmware']['account_file'],
  'source_image' => 'centos7-template',
  'ssh_username' => 'root' # required on CentOS
}

default['marketplace_image']['vmware']['aio']['products'] =
  [5, 25, 50, 100, 150, 200, 250].map do |node_count|
    {
      'name' => "vmware_aio_#{node_count}",
      'builder_options' => vmware_builder_config.merge(
        'image_name' => "Chef_AIO_#{node_count}_{{timestamp}}"
      ),
      'marketplace_config_options' => default_marketplace_config.merge(
        'license_count' => node_count
      ),
    }
  end

default['marketplace_image']['vmware']['compliance']['products'] =
  [5, 25, 50, 100, 150, 200, 250].map do |node_count|
    {
      'name' => "vmware_compliance_#{node_count}",
      'builder_options' => vmware_builder_config.merge(
        'image_name' => "Chef_Compliance_#{node_count}_{{timestamp}}"
      ),
      'marketplace_config_options' => default_marketplace_config.merge(
        'license_count' => node_count,
        'role' => 'compliance',
        'doc_url' => 'https://docs.chef.io/install_compliance.html#vmware'
      ),
    }
  end
