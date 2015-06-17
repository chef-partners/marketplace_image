default['marketplace_image']['marketplace'] = 'aws'
default['marketplace_image']['chef_server_version'] = nil
default['marketplace_image']['opscode_reporting_version'] = nil
default['marketplace_image']['opscode_manage_version'] = nil
default['marketplace_image']['license_count'] = 25
default['marketplace_image']['support_email'] = 'aws@chef.io'
default['marketplace_image']['aws_origin_image_id'] = 'ami-1d7d8a76'
default['marketplace_image']['aws_products'] = [
  { 'node_count' => 5, 'product_code' => 'dzsysio0zch27uban3y1c6wh7' },
  { 'node_count' => 25, 'product_code' => '349645nlgkwcdfb8ndjeiwwp7' },
  { 'node_count' => 50, 'product_code' => 'ckwjikuom9b37yaprlidzbqps' },
  { 'node_count' => 100, 'product_code' => 'q995h875sbckcpafm8up762' },
  { 'node_count' => 150, 'product_code' => '28ac4pvihsw8uoy2sukb0ihzu' },
  { 'node_count' => 200, 'product_code' => '3nmsqv0670zsfjnqfnyd7lmdi' },
  { 'node_count' => 250, 'product_code' => 'cfnnw6j8s75mhj3i5na0t4afq' }
]

default['openssh']['server'].tap do |server|
  server['protocol'] = 2
  server['syslog_facility'] = 'AUTHPRIV'
  server['permit_root_login'] = 'no'
  server['r_s_a_authentication'] = 'yes'
  server['pubkey_authentication'] = 'yes'
  server['password_authentication'] = 'no'
  server['authorized_keys_file'] = '.ssh/authorized_keys'
  server['challenge_response_authentication'] = 'no'
  server['g_s_s_a_p_i_authentication'] = 'yes'
  server['g_s_s_a_p_i_cleanup_credentials'] = 'yes'
  server['use_p_a_m'] = 'yes'
  server['use_d_n_s'] = 'no'
  server['Subsystem'] = 'sftp    /usr/libexec/openssh/sftp-server'
end

%w(base extras plus updates).each do |repo|
  default['yum'][repo]['enabled'] = true
  default['yum'][repo]['managed'] = true
end
