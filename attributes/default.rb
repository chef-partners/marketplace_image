default['marketplace_image']['platform'] = 'aws'
default['marketplace_image']['role'] = 'server'
default['marketplace_image']['chef_server_version'] = 'latest'
default['marketplace_image']['reporting_version'] = 'latest'
default['marketplace_image']['manage_version'] = 'latest'
default['marketplace_image']['analytics_version'] = 'latest'
default['marketplace_image']['license_count'] = 5
default['marketplace_image']['support_email'] = 'aws@chef.io'
default['marketplace_image']['marketplace_url'] = 'https://docs.chef.io/aws_marketplace.html'

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
