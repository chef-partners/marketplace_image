default['marketplace_image']['azure']['aio']['enabled'] = false
default['marketplace_image']['azure']['compliance']['enabled'] = false

cred_dir = ::File.expand_path(::File.join('~', '.azure'))
publish_settings_path = ::File.join(cred_dir, 'marketplace.publish_settings')

default_marketplace_config = {
  'role' => 'aio',
  'platform' => 'azure',
  'user' => 'ubuntu',
  'support_email' => 'support@chef.io',
  'reporting_cron_enabled' => true,
  'doc_url' => 'https://docs.chef.io/azure_portal.html#azure-marketplace',
  'disable_outbound_traffic' => false,
  'license_count' => 25,
  'license_type' => 'fixed',
  'free_node_count' => 5
}

azure_builder_config = {
  'name' => 'azure',
  'type' => 'azure',
  'publish_settings_path' => publish_settings_path,
  'subscription_name' => 'Partner Engineering',
  'storage_account' => 'ampimages',
  'storage_account_container' => 'images',
  'os_type' => 'Linux',
  'os_image_label' => 'Ubuntu Server 14.04 LTS',
  'location' => 'East US',
  'instance_size' => 'Large',
  'user_image_label' => 'azure'
}

default['marketplace_image']['azure']['cred_dir'] = cred_dir
default['marketplace_image']['azure']['publish_settings_path'] = publish_settings_path

default['marketplace_image']['azure']['aio']['products'] =
  ['BYOL', 25, 50, 100, 150, 200, 250].map do |node_count|
    {
      'name' => "azure_aio_#{node_count}",
      'builder_options' => azure_builder_config.merge(
        'name' => "azure_aio_#{node_count}",
        'user_image_label' => "Chef_AIO_#{node_count}_{{timestamp}}"
      ),
      'marketplace_config_options' => default_marketplace_config.merge(
        'license_count' => node_count.is_a?(Integer) ? node_count : 25
      )
    }
  end

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
        'role' => 'compliance'
      )
    }
  end
