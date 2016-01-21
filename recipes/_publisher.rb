#
# Cookbook Name:: marketplace_image
# Recipe:: _publisher
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

marketplace_image node['marketplace_image']['role'] do
  platform                  node['marketplace_image']['platform']
  default_user              node['marketplace_image']['default_user']
  support_email             node['marketplace_image']['support_email']
  reporting_cron            node['marketplace_image']['reporting_cron']
  publish                   node['marketplace_image']['publish']
  disable_outbound_traffic  node['marketplace_image']['disable_outbound_traffic']
  license_count             node['marketplace_image']['license_count']
  license_type              node['marketplace_image']['license_type']
  doc_url                   node['marketplace_image']['doc_url']
  product_code              node['marketplace_image']['product_code']
end
