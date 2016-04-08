# Images that should have been built are saved to a manifest for later smoke testing
file '/tmp/marketplace_image_manifest.json' do
  content JSON.pretty_generate(enabled_image_names)
end

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

packer_provisioner 'yum_upgrade' do
  type 'shell'
  source 'yum_upgrade.sh.erb'
  except azure_builders
end

packer_provisioner 'prepare_for_publishing' do
  type 'shell'
  source 'prepare_for_publishing.sh.erb'
end

packer_provisioner 'sudo rm -f /etc/chef-manage/manage.rb' do
  type 'shell'
  inline true
  inline_shebang '/bin/bash'
end

packer_provisioner 'sudo rm -f /etc/chef-compliance/chef-compliance.rb' do
  type 'shell'
  inline true
  inline_shebang '/bin/bash'
end

packer_template 'marketplace_images' do
  only enabled_builders
end
