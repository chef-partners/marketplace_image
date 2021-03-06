# frozen_string_literal: true
apt_update 'update' do
  action :update
  only_if { node['platform_family'] == 'debian' }
end

include_recipe 'packman::default'

bash 'ulimit -n unlimited' do
  not_if { node['platform_family'] == 'debian' }
end

creds = data_bag_item('marketplace_image', 'publishing_credentials')

if creds['aws']
  directory node['marketplace_image']['aws']['cred_dir']

  template node['marketplace_image']['aws']['credential_file'] do
    sensitive true
    source 'aws_credentials.erb'
    variables creds['aws']
  end
end

if creds['gce']
  directory node['marketplace_image']['gce']['cred_dir']

  file node['marketplace_image']['gce']['account_file'] do
    sensitive true
    content JSON.pretty_generate(creds['gce']['account'])
  end
end
