#
# Cookbook Name:: marketplace_image
# Recipe:: default
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

include_recipe 'marketplace_image::_bootstrap'
include_recipe "marketplace_image::_#{node['marketplace_image']['marketplace']}"
# Do host security last because it wipes out cookbooks in the cache
include_recipe 'marketplace_image::_security'

ruby_block 'hack to prevent node save' do
  block { Chef::Config[:solo] = true }
end
