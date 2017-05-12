# frozen_string_literal: true
default['marketplace_image']['gce']['aio']['enabled'] = false
default['marketplace_image']['gce']['compliance']['enabled'] = false

cred_dir = ::File.expand_path(::File.join('~', '.gce'))
account_file = ::File.join(cred_dir, 'account.json')

default['marketplace_image']['gce']['cred_dir'] = cred_dir
default['marketplace_image']['gce']['account_file'] = account_file

default_marketplace_config = {
  'role' => 'aio',
  'platform' => 'gce',
  'support_email' => 'cloud-marketplaces@chef.io',
  'reporting_cron_enabled' => true,
  'doc_url' => 'https://docs.chef.io/google_marketplace.html',
  'disable_outbound_traffic' => false,
  'license_count' => 25,
  'license_type' => 'fixed',
  'free_node_count' => 5,
}

gce_builder_config = {
  'type' => 'googlecompute',
  'account_file' => node['marketplace_image']['gce']['account_file'],
  'project_id' => 'chef-marketplace-dev',
  'source_image' => 'centos-7-v20160126',
  'zone' => 'us-central1-a',
  'ssh_username' => 'marketplace' # required on CentOS
}

default['marketplace_image']['gce']['aio']['products'] =
  [5, 25, 50, 100, 150, 200, 250].map do |node_count|
    {
      'name' => "gce_aio_#{node_count}",
      'builder_options' => gce_builder_config.merge(
        'image_name' => "Chef_AIO_#{node_count}_{{timestamp}}"
      ),
      'marketplace_config_options' => default_marketplace_config.merge(
        'license_count' => node_count
      ),
    }
  end

default['marketplace_image']['gce']['compliance']['products'] =
  [5, 25, 50, 100, 150, 200, 250].map do |node_count|
    {
      'name' => "gce_compliance_#{node_count}",
      'builder_options' => gce_builder_config.merge(
        'image_name' => "Chef_Compliance_#{node_count}_{{timestamp}}"
      ),
      'marketplace_config_options' => default_marketplace_config.merge(
        'license_count' => node_count,
        'role' => 'compliance',
        'doc_url' => 'https://docs.chef.io/install_compliance.html#google-marketplace'
      ),
    }
  end
