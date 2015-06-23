#
# Cookbook Name:: marketplace_image
# Recipe:: _bootstrap_analytics
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

chef_ingredient 'analytics' do
  version node['marketplace_image']['analytics_version']
  action :install
end

chef_ingredient 'chef-server' do
  action :uninstall
end

chef_ingredient 'reporting' do
  action :uninstall
end

chef_ingredient 'manage' do
  action :uninstall
end

motd '50-chef-marketplace-appliance' do
  source 'analytics-motd.erb'
  cookbook 'marketplace_image'
  variables support_email: node['marketplace_image']['support_email']
end

package 'cloud-init' do
  action :install
end

directory '/etc/chef/ohai/hints' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end
