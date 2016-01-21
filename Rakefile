require 'json'
require 'tempfile'

def start_chef_zero
  @zero_pid = spawn('chef-zero -p 8899')
  Process.detach(@zero_pid)
  @zero_pid
end

def stop_chef_zero
  Process.kill('HUP', @zero_pid)
end

def berks_install
  system('berks install && berks upload')
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
