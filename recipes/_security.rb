#
# Cookbook Name:: marketplace_image
# Recipe:: _aws
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

include_recipe 'openssh::default'

control_group 'marketplace image' do
  let(:user_dirs) do
    Etc::Passwd.each_with_object({}) do |user, memo|
      next if %w(vagrant halt sync shutdown).include?(user.name) ||
              user.shell =~ %r{(/sbin/nologin|/bin/false)}
      memo[user.name] = user.dir
    end
  end

  control 'ssh access' do
    it 'does not have any default keys' do
      user_dirs.each do |_, dir|
        expect(file("#{dir}/.ssh/id_rsa")).to_not be_file
        expect(file("#{dir}/.ssh/id_rsa.pub")).to_not be_file
        expect(file("#{dir}/.ssh/authorized_keys")).to_not be_file
      end

      %w(key dsa_key rsa_key).each do |key|
        expect(file("/etc/ssh/ssh_host_#{key}")).to_not be_file
        expect(file("/etc/ssh/ssh_host_#{key}.pub")).to_not be_file
      end
    end if node['marketplace_image']['wipe_ssh_keys']

    it 'is listening on port 22' do
      expect(port(22)).to be_listening
    end

    it 'does not allow root login' do
      expect(file('/etc/ssh/sshd_config')).to contain('PermitRootLogin no')
    end

    it 'disables DNS checks' do
      expect(file('/etc/ssh/sshd_config')).to contain('UseDNS no')
    end

    it 'has cloud-init enabled' do
      expect(package('cloud-init')).to be_installed
    end
  end

  control 'root user' do
    it 'does not have a password' do
      expect(command('passwd -S root').stdout).to match(/Password locked/)
    end
  end

  control 'chef config' do
    it 'does not have chef config' do
      expect(file('/etc/chef')).to_not be_directory
      expect(file('/var/chef')).to_not be_directory

      user_dirs.each do |_, dir|
        expect(file("#{dir}/.chef")).to_not be_directory
      end
    end
  end

  control 'history' do
    it 'does not common logs' do
      expect(file('/var/log/chef')).to_not be_file
    end

    it 'does not have user shell history' do
      user_dirs.each do |_, dir|
        expect(file("#{dir}/.bash_history")).to_not be_file
      end
    end
  end
end
