# frozen_string_literal: true

default['marketplace_image']['azure']['automate']['enabled'] = false

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
  'image_sku' => '16.04-LTS',
  'image_version' => 'latest',
  'location' => 'East US',
  'vm_size' => 'Standard_D3_v2',
  'capture_name_prefix' => 'Chef_Automate_BYOL',
}

default['marketplace_image']['azure']['automate'] = {
  'name' => 'azure_automate_BYOL',
  'builder_options' => azure_builder_config,
  'marketplace_config_options' => default_marketplace_config,
}
