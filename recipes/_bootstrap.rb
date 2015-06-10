#
# Cookbook Name:: marketplace_image
# Recipe:: _bootstrap
#
# Copyright (C) 2015 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'yum-centos::default'

chef_server_ingredient 'chef-server-core' do
  version node['marketplace_image']['chef_server_version']
  action :install
end

chef_server_ingredient 'opscode-reporting' do
  version node['marketplace_image']['opscode_reporting_version']
  action :install
end

chef_server_ingredient 'opscode-manage' do
  version node['marketplace_image']['opscode_manage_version']
  action :install
end

%w(opscode opscode-manage).each do |dir|
  directory ::File.join('etc', dir) do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end
end

template '/etc/opscode/chef-server.rb' do
  source 'chef-server.rb.erb'
  owner 'root'
  group 'root'
  variables marketplace: node['marketplace_image'].to_h
  action :create
end

template '/etc/opscode-manage/manage.rb' do
  source 'manage.rb.erb'
  owner 'root'
  group 'root'
  action :create
end

template '/opt/opscode/embedded/service/omnibus-ctl/marketplace_setup.rb' do
  source 'marketplace_setup.rb'
  owner 'root'
  group 'root'
  action :create
end

motd '50-chef-marketplace-appliance' do
  source 'marketplace-motd.erb'
  cookbook 'marketplace_image'
  variables support_email: node['marketplace_image']['support_email']
end

package 'cloud-init' do
  action :install
end

include_recipe 'marketplace_image::_security'
