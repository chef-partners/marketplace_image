default['marketplace_image']['aws']['public']['aio']['enabled'] = false
default['marketplace_image']['aws']['public']['aio']['fcp_enabled'] = false
default['marketplace_image']['aws']['public']['compliance']['enabled'] = false
default['marketplace_image']['aws']['public']['compliance']['fcp_enabled'] = false
default['marketplace_image']['aws']['ic']['aio']['enabled'] = false
default['marketplace_image']['aws']['ic']['compliance']['enabled'] = false
default['marketplace_image']['aws']['aio']['source_ami'] = 'ami-533ad43e'
default['marketplace_image']['aws']['compliance']['source_ami'] = 'ami-533ad43e'

cred_dir = ::File.expand_path(::File.join('~', '.aws'))
credential_file = ::File.join(cred_dir, 'credentials')

@timestamp = Time.now.strftime('%Y_%m_%d_%H_%M_%S')
@invalid_ami_name_characters = /[^\w\(\)\.\-\/]/

def normalize_name(name)
  # Append timestamp
  # Remove invalid characters
  # Ensure it's 128 characters or less
  "#{name}_#{@timestamp}".gsub(@invalid_ami_name_characters, '').strip[0..127]
end

default['marketplace_image']['aws']['cred_dir'] = cred_dir
default['marketplace_image']['aws']['credential_file'] = credential_file

default_marketplace_config = {
  'role' => 'aio',
  'platform' => 'aws',
  'user' => 'ec2-user',
  'support_email' => 'aws@chef.io',
  'reporting_cron_enabled' => true,
  'doc_url' => 'https://docs.chef.io/aws_marketplace.html',
  'disable_outbound_traffic' => false,
  'license_count' => 25,
  'license_type' => 'fixed',
  'free_node_count' => 5
}

aws_builder_config = {
  'type' => 'amazon-ebs',
  'region' => 'us-east-1',
  'source_ami' => node['marketplace_image']['aws']['aio']['source_ami'],
  'instance_type' => 'm4.xlarge',
  'ssh_username' => 'ec2-user',
  'ssh_pty' => 'true',
  'ami_name' => 'amazon'
}

default['marketplace_image']['aws']['public']['aio']['products'] =
  {
    5 => 'dzsysio0zch27uban3y1c6wh7',
    25 => '349645nlgkwcdfb8ndjeiwwp7',
    50 => 'ckwjikuom9b37yaprlidzbqps',
    100 => 'q995h875sbckcpafm8up762',
    150 => '28ac4pvihsw8uoy2sukb0ihzu',
    200 => '3nmsqv0670zsfjnqfnyd7lmdi',
    250 => 'cfnnw6j8s75mhj3i5na0t4afq'
  }.map do |node_count, product_code|
    {
      'name' => "aws_public_aio_#{node_count}",
      'builder_options' => aws_builder_config.merge(
        'ami_name' => normalize_name("public_aio_#{node_count}"),
        'ami_product_codes' => [product_code]
      ),
      'marketplace_config_options' => default_marketplace_config.merge(
        'license_count' => node_count,
        'product_code' => product_code
      )
    }
  end

default['marketplace_image']['aws']['public']['compliance']['products'] =
  {
    5 => '148p1m5zz5zhinwoggpqeavis',
    25 => '7vylx7v9xdlma0mj2apjyix9w',
    50 => 'c8vcwhxd8seccf77fz1ccgpe4',
    100 => 'a5mqx9w3n56pvjedo8iw0toj2',
    150 => 'gg239559lun7g9v74fc9caj5',
    200 => '86ocpc6jfmdp9jcej5oyji1rz',
    250 => 'ezw9hgu9mtlvqwkayp5gw15is'
  }.map do |node_count, product_code|
    {
      'name' => "aws_public_compliance_#{node_count}",
      'builder_options' => aws_builder_config.merge(
        'source_ami' => node['marketplace_image']['aws']['compliance']['source_ami'],
        'ami_name' => normalize_name("public_compliance_#{node_count}"),
        'ami_product_codes' => [product_code]
      ),
      'marketplace_config_options' => default_marketplace_config.merge(
        'license_count' => node_count,
        'product_code' => product_code,
        'role' => 'compliance'
      )
    }
  end

default['marketplace_image']['aws']['ic']['aio']['products'] =
  {
    5 => 'dgivcepn261oi5ul0fdxu6drf',
    25 => 'cntn7cg2u1iiwv0eah6fnkkbj',
    50 => 'ax4j22h69yeb5824i1qhobdaw',
    100 => 'dqbbw3v3mqcm5vvr8fdgrw0cy',
    150 => 'dqvg1zvlvsch9fsnajua0e3df',
    200 => '6p9oh9isrga3p00bwfobn8gr0',
    250 => 'c4yh8519ogsqr344akhv9jk91'
  }.map do |node_count, product_code|
    {
      'name' => "aws_ic_aio_#{node_count}",
      'builder_options' => aws_builder_config.merge(
        'ami_name' => normalize_name("ic_aio_#{node_count}"),
        'ami_product_codes' => [product_code]
      ),
      'marketplace_config_options' => default_marketplace_config.merge(
        'license_count' => node_count,
        'product_code' => product_code,
        'disable_outbound_traffic' => true
      )
    }
  end

default['marketplace_image']['aws']['ic']['compliance']['products'] =
  {
    5 => 'es45a780wiqmxb7wzcxsnqoho',
    25 => 'pa64tibm2rwx0azxn51cgq48',
    50 => 'e3z71pfxnk7r22tx11fxjsso',
    100 => 'bjg704s75oq34nrg9sg9zex8v',
    150 => '1igoiq6sm5nq6j4tbzr9p2z3z',
    200 => '5igut39qk86ttq9qztlhmncrb',
    250 => 'bv1cblebexhoamj2ief0t3sih'
  }.map do |node_count, product_code|
    {
      'name' => "aws_ic_compliance_#{node_count}",
      'builder_options' => aws_builder_config.merge(
        'source_ami' => node['marketplace_image']['aws']['compliance']['source_ami'],
        'ami_name' => normalize_name("ic_compliance_#{node_count}"),
        'ami_product_codes' => [product_code]
      ),
      'marketplace_config_options' => default_marketplace_config.merge(
        'license_count' => node_count,
        'product_code' => product_code,
        'role' => 'compliance',
        'disable_outbound_traffic' => true
      )
    }
  end

default['marketplace_image']['aws']['public']['aio']['fcp'] =
  {
    'name' => 'aws_public_aio_flexible',
    'builder_options' => aws_builder_config.merge(
      'ami_product_codes' => ['dlna41ywkqax795eganhflsm8'],
      'ami_name' => normalize_name('public_aio_flexible')
    ),
    'marketplace_config_options' => default_marketplace_config.merge(
      'license_type' => 'flexible',
      'product_code' => 'dlna41ywkqax795eganhflsm8'
    )
  }
default['marketplace_image']['aws']['public']['compliance']['fcp'] =
  {
    'name' => 'aws_public_compliance_flexible',
    'builder_options' => aws_builder_config.merge(
      'source_ami' => node['marketplace_image']['aws']['compliance']['source_ami'],
      'ami_product_codes' => ['8a3w64phkkutljzrbdqjrmc8f'],
      'ami_name' => normalize_name('public_compliance_flexible')
    ),
    'marketplace_config_options' => default_marketplace_config.merge(
      'license_type' => 'flexible',
      'product_code' => '8a3w64phkkutljzrbdqjrmc8f',
      'role' => 'compliance'
    )
  }
