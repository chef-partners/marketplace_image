# frozen_string_literal: true

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

creds = Chef::DataBagItem.load('marketplace_image', 'publishing_credentials')

azure_builder_config = {
  'name' => 'azure_automate_BYOL',
  'type' => 'azure-arm',
  'subscription_id' => "#{creds['azure']['subscription_id']}",
  'client_id' => "#{creds['azure']['client_id']}",
  'client_secret' => "#{creds['azure']['client_secret']}",
  'resource_group_name' => 'publish-marketplace-images',
  'storage_account' => 'marketplaceimages',
  'capture_container_name' => 'vhds',
  'os_type' => 'Linux',
  'image_publisher' => 'Canonical',
  'image_offer' => 'UbuntuServer',
  'image_sku' => '14.04.5-LTS',
  'location' => 'East US',
  'vm_size' => 'Standard_D3_v2',
  'capture_name_prefix' => 'Chef_Automate_BYOL',
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
