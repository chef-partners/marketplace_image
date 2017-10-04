# frozen_string_literal: true
default['marketplace_image']['vmware']['aio']['enabled'] = false
default['marketplace_image']['vmware']['compliance']['enabled'] = false

override['packman']['checksums']['1.1.0'] = 'bd1eddfa114f7e6258ef3419613380297f1b4e438f5bae92f1177150519be934'

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
  'type' => 'vmware-iso',
	'iso_url' => 'http://mirror.rackspace.com/CentOS/7/isos/x86_64/CentOS-7-x86_64-Minimal-1708.iso',
	'iso_checksum' => 'bba314624956961a2ea31dd460cd860a77911c1e0a56e4820a12b9c5dad363f5',
	'iso_checksum_type' => 'sha256',
	'ssh_username' => 'root',
	'ssh_password' => node['vmware']['packer_ssh_password'],
	'ssh_wait_timeout' => '30m',
	'floppy_files' => [
		'/tmp/ks.cfg'
	],
	'boot_command' => '<tab> inst.text inst.ks=hd:fd0:/ks.cfg <enter><wait>',
	'shutdown_command' => 'shutdown -P now',
	'remote_type' => 'esx5',
	'remote_host' => node['vmware']['esx_host'],
	'remote_username' => 'root',
	'remote_password' => node['vmware']['esx_password'],
	'vnc_disable_password' => 'true',
	'format' => 'ova',
	'vmx_data' => {
		'ethernet0.networkName' => 'VM Network'
	}
}

default['marketplace_image']['vmware']['aio']['products'] =
  #[5, 25, 50, 100, 150, 200, 250].map do |node_count|
  [250].map do |node_count|
    {
      'name' => "vmware_aio_#{node_count}",
      'builder_options' => vmware_builder_config,
      #'builder_options' => vmware_builder_config.merge(
      #  'image_name' => "Chef_AIO_#{node_count}_{{timestamp}}"
      #),
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
