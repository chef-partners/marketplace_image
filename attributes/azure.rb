# frozen_string_literal: true
cred_dir = ::File.expand_path(::File.join('~', '.azure'))
publish_settings_path = ::File.join(cred_dir, 'marketplace.publish_settings')

default['marketplace_image']['azure']['cred_dir'] = cred_dir
default['marketplace_image']['azure']['publish_settings_path'] = publish_settings_path

default['marketplace_image']['azure']['automate']['enabled'] = false
default['marketplace_image']['azure']['compliance']['enabled'] = false

default_marketplace_config = {
  'role' => 'automate',
  'platform' => 'azure',
  'user' => 'ubuntu',
  'support_email' => 'support@chef.io',
  'sales_email' => 'amp@chef.io',
  'reporting_cron_enabled' => true,
  'doc_url' => 'https://docs.chef.io/azure_portal.html#chef-automate',
  'disable_outbound_traffic' => false,
  'license_type' => 'BYOL',
  'free_node_count' => 5,
}

azure_builder_config = {
  'name' => 'azure_automate_BYOL',
  'type' => 'azure',
  'publish_settings_path' => publish_settings_path,
  'subscription_name' => 'Partner Engineering',
  'storage_account' => 'ampimages',
  'storage_account_container' => 'images',
  'os_type' => 'Linux',
  'os_image_label' => 'Ubuntu Server 14.04 LTS',
  'location' => 'East US',
  'instance_size' => 'Large',
  'user_image_label' => 'Chef_Automate_BYOL_{{timestamp}}',
}

default['marketplace_image']['azure']['automate'] = {
  'name' => 'azure_automate_BYOL',
  'builder_options' => azure_builder_config,
  'marketplace_config_options' => default_marketplace_config,
}

default['marketplace_image']['azure']['compliance']['products'] =
  [5, 25, 50, 100, 150, 200, 250].map do |node_count|
    {
      'name' => "azure_compliance_#{node_count}",
      'builder_options' => azure_builder_config.merge(
        'name' => "azure_compliance_#{node_count}",
        'user_image_label' => "Chef_Compliance_#{node_count}_{{timestamp}}"
      ),
      'marketplace_config_options' => default_marketplace_config.merge(
        'license_count' => node_count,
        'license_type' => 'fixed',
        'role' => 'compliance'
      ),
    }
  end
