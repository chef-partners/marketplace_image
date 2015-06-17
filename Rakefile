desc 'Build AWS Marketplace Images'
task :build_aws do
  # Start chef-zero
  zero_pid = spawn('chef-zero')
  Process.detach(zero_pid)

  # Populate it with our cookbooks
  system('berks install && berks upload')

  # Run the provisioning recipe
  system("chef-client -c .chef/client.rb -o 'marketplace_image::_aws_publisher'")

  # Reap chef-zero
  Process.kill('HUP', zero_pid)
end
