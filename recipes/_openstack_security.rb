#
# Cookbook Name:: marketplace_image
# Recipe:: _openstack_security
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

control_group 'openstack' do
  control 'default user' do
    it 'is a user' do
      expect(user('openstack-user')).to exist
      expect(user('openstack-user')).to have_home_directory('/home/openstack-user')
      expect(user('openstack-user')).to have_login_shell('/bin/bash')
    end

     it 'does not have a password' do
      expect(command('passwd -S openstack-user').stdout).to match(/Password locked/)
    end
  end
end
