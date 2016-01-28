#
# Author:: Partner Engineering <partnereng@chef.io>
# Copyright (c) 2016, Chef Software, Inc. <legal@chef.io>
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

require 'rake'
require 'json'
require 'tempfile'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

def start_chef_zero
  @zero_pid = spawn('chef-zero -p 8899')
  Process.detach(@zero_pid)
  @zero_pid
end

def stop_chef_zero
  Process.kill('HUP', @zero_pid)
end

def berks_install(hosted = false)
  use_hosted = hosted ? 'USE_HOSTED=1 ' : ''
  cmd = "#{use_hosted} berks install && #{use_hosted} berks upload --force"
  system(cmd)
end

def write_client_json(params)
  @client_json_file = Tempfile.new('client.json')
  @client_json_file.write(JSON.pretty_generate(params))
  @client_json_file.rewind
end

def delete_client_json
  return unless defined?(@client_json_file)
  @client_json_file.close
  @client_json_file.unlink
end

def purge_nodes_and_clients
  nodes = `USE_HOSTED=1 knife node list`.split("\n")
  return if nodes.empty?

  system("USE_HOSTED=1 knife node delete -y #{nodes.join(' ')}")
  system("USE_HOSTED=1 knife client delete -y #{nodes.join(' ')}")
end

def gce_config
  gce_config_file = File.join(File.expand_path(File.dirname(__FILE__)), '.chef', 'gce_config.json')
  fail "Please create a gce_config.json at #{gce_config_file}" unless File.exist?(gce_config_file)

  JSON.load(File.read(gce_config_file))
end

# Amazon
desc 'Publish AWS Marketplace Images'
task :publish_aws, :marketplace, :product do |_, params|
  begin
    write_client_json('marketplace_image' => params.to_h)
    start_chef_zero
    berks_install
    system("chef-client -c .chef/client.rb -o 'marketplace_image::aws_publisher' -j #{@client_json_file.path}")
  ensure
    delete_client_json
    stop_chef_zero
  end
end

desc 'Build AWS AIO images for the public marketplace'
task :publish_aws_aio_public do
  Rake::Task['publish_aws'].invoke('public', 'aio')
end

desc 'Build AWS AIO images for the ic marketplace'
task :publish_aws_aio_ic do
  Rake::Task['publish_aws'].invoke('ic', 'aio')
end

desc 'Build flexible AWS AIO images'
task :publish_aws_aio_flexible do
  Rake::Task['publish_aws'].invoke('public', 'flexible_aio')
end

desc 'Build AWS Compliance images for the public marketplace'
task :publish_aws_compliance_public do
  Rake::Task['publish_aws'].invoke('public', 'compliance')
end

desc 'Build AWS Compliance images for the ic marketplace'
task :publish_aws_compliance_ic do
  Rake::Task['publish_aws'].invoke('ic', 'compliance')
end

desc 'Build flexible AWS Compliance images'
task :publish_aws_compliance_flexible do
  Rake::Task['publish_aws'].invoke('public', 'flexible_compliance')
end

desc 'Build all flexible images'
task :publish_aws_flexible_all do
  Rake::Task['publish_aws'].invoke('public', 'flexible_aio')
  Rake::Task['publish_aws'].reenable
  Rake::Task['publish_aws'].invoke('public', 'flexible_compliance')
end

desc 'Build all public images'
task :publish_aws_public_all do
  Rake::Task['publish_aws'].invoke('public', 'aio')
  Rake::Task['publish_aws'].reenable
  Rake::Task['publish_aws'].invoke('public', 'compliance')
  Rake::Task['publish_aws'].reenable
  Rake::Task['publish_aws'].invoke('public', 'flexible_aio')
  Rake::Task['publish_aws'].reenable
  Rake::Task['publish_aws'].invoke('public', 'flexible_compliance')
end

desc 'Build all IC images'
task :publish_aws_ic_all do
  Rake::Task['publish_aws'].invoke('ic', 'aio')
  Rake::Task['publish_aws'].reenable
  Rake::Task['publish_aws'].invoke('ic', 'compliance')
end

desc 'Build all AIO images'
task :publish_aws_aio_all do
  Rake::Task['publish_aws'].invoke('public', 'aio')
  Rake::Task['publish_aws'].reenable
  Rake::Task['publish_aws'].invoke('public', 'flexible_aio')
  Rake::Task['publish_aws'].reenable
  Rake::Task['publish_aws'].invoke('ic', 'aio')
end

desc 'Build all Compliance images'
task :publish_aws_compliance_all do
  Rake::Task['publish_aws'].invoke('public', 'compliance')
  Rake::Task['publish_aws'].reenable
  Rake::Task['publish_aws'].invoke('public', 'flexible_compliance')
  Rake::Task['publish_aws'].reenable
  Rake::Task['publish_aws'].invoke('ic', 'compliance')
end

desc 'Build AWS Analytics Marketplace Images'
task :publish_aws_analytics do
  Rake::Task['publish_aws'].invoke('ic', 'compliance')
end

desc 'Build AWS Analytics Marketplace Images'
task :publish_aws_analytics do
  start_chef_zero
  berks_install
  system("chef-client -c .chef/client.rb -o 'marketplace_image::aws_analytics_publisher'")
  stop_chef_zero
end

# Google
desc 'Publish GCE Marketplace Images'
task :publish_gce, :marketplace, :product, :release_version do |_, params|
  begin
    write_client_json('marketplace_image' => params.to_h, 'gce' => gce_config)
    start_chef_zero
    berks_install
    berks_install(true)
    system("chef-client -c .chef/client.rb -o 'marketplace_image::gce_publisher' -j #{@client_json_file.path} -l info")
  ensure
    delete_client_json
    stop_chef_zero
    purge_nodes_and_clients
  end
end

desc 'Build GCE AIO images for the public marketplace'
task :publish_gce_aio_public, :version do |_, params|
  params.with_defaults(version: '0.0.1')
  Rake::Task['publish_gce'].invoke('public', 'aio', params[:version])
end

# Rubocop
desc 'Run Rubocop style checks'
RuboCop::RakeTask.new(:rubocop) do |cop|
  cop.fail_on_error = true
end

# RSpec
desc 'Run RSpec/ChefSpec examples'
RSpec::Core::RakeTask.new(:spec)

desc 'Default task: run all tests'
task default: [:rubocop, :spec]
