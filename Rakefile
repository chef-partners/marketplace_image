require 'rake'
require 'json'
require 'tempfile'
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
  cmd = hosted ? 'USE_HOSTED=1 ' : ''
  cmd << 'berks install && berks upload --force'
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
task :publish_gce, :marketplace, :product do |_, params|
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
task :publish_gce_aio_public do
  Rake::Task['publish_gce'].invoke('public', 'aio')
end

# Rubocop
desc 'Run Rubocop style checks'
RuboCop::RakeTask.new do |cop|
  cop.fail_on_error = true
end

desc 'Default task: rubocop'
task default: %w(rubocop)
