marketplace_products.each do |product|
  packer_builder product['name'] do
    options product['builder_options']
  end

  packer_provisioner "marketplace_#{product['name']}.rb" do
    type 'file'
    source 'marketplace.rb.erb'
    destination '/tmp/marketplace.rb'
    variables product['marketplace_config_options']
    only [product['name']]
  end
end

packer_provisioner '/tmp/chef-server.rb' do
  type 'file'
  source 'chef-server.rb.erb'
end

packer_provisioner 'setup_marketplace' do
  type 'shell'
  source 'setup_marketplace.sh.erb'
end

packer_provisioner 'apt_upgrade' do
  type 'shell'
  source 'apt_upgrade.sh.erb'
  only azure_builders
end

packer_provisioner 'sudo apt-get install walinuxagent -y' do
  type 'shell'
  inline true
  only azure_builders
end

packer_provisioner 'yum_upgrade' do
  type 'shell'
  source 'yum_upgrade.sh.erb'
  except azure_builders
end

packer_provisioner 'prepare_for_publishing' do
  type 'shell'
  source 'prepare_for_publishing.sh.erb'
end

# TODO: Remove these two provisioners after chef-marketplace 0.0.7 has been released
packer_provisioner "echo 'ClientAliveInterval 180' | sudo tee -a /etc/ssh/sshd_config" do
  type 'shell'
  inline true
  only azure_builders
end

packer_provisioner 'sudo mkdir -p /opt/chef-compliance/{sv,init,service}' do
  type 'shell'
  inline true
  inline_shebang '/bin/bash'
  only azure_builders
end

packer_template 'marketplace_images' do
  only enabled_builders
end
