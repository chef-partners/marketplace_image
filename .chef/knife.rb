log_level                :info
log_location             STDOUT
private_key 'marketplace_builder' => ENV['MARKETPLACE_BUILDER_SSH_KEY_PATH']

if ENV['USE_HOSTED'] == '1'
  raise 'Please set the HOSTED_USER environment variable to your Hosted Chef Manage username.' unless ENV['HOSTED_USER']

  node_name        ENV['HOSTED_USER']
  chef_server_url  'https://api.opscode.com/organizations/chef-partners-marketplaces'
  client_key       File.join(File.expand_path(File.dirname(__FILE__)), 'hosted.pem')
else
  node_name        "zero"
  chef_server_url  'http://127.0.0.1:8899'
end
