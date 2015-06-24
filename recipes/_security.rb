#
# Cookbook Name:: marketplace_image
# Recipe:: _security
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

# openssh::default does a late restart of sshd in the event that the sshd_config
# template changes.  Force it to restart immediately so it isn't restarted
# after we remove the keys.  During the restart it will auto generate keys if they
# are missing, something that we want to happen when the image boots for the first
# time.
include_recipe 'marketplace_image::_security_controls'

%w(openssh-clients openssh-server).each do |pkg|
  package pkg do
    action :install
  end
end

template '/etc/ssh/sshd_config' do
  source 'sshd-config.erb'
  mode '0600'
  owner 'root'
  group 'root'
end

service 'sshd' do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end

MarketplaceHelpers.user_directories.each do |usr, dir|
  %w(id_rsa id_rsa.pub authorized_keys).each do |ssh_file|
    file ::File.join(dir, '.ssh', ssh_file) do
      action :delete
    end
  end

  user usr do
    action :lock
  end

  file ::File.join(dir, '.bash_history') do
    action :delete
  end
end

MarketplaceHelpers.system_ssh_keys.each do |key|
  file key do
    action :delete
  end
end

MarketplaceHelpers.sudoers.each do |sudo_user|
  file sudo_user do
    action :delete
  end
end

%w(/etc/chef/client.rb /etc/chef/client.pem).each do |chef_file|
  file chef_file do
    action :delete
  end
end

directory '/var/log' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/tmp' do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end

execute 'rm -rf /tmp/*' do
  not_if { Dir['/tmp/*'].empty? }
end

execute 'rm -rf /var/log/*' do
  not_if { Dir['/var/log/*'].empty? }
end
