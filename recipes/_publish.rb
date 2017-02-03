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

packer_provisioner 'setup_marketplace' do
  type 'shell'
  source 'setup_marketplace.sh.erb'
end

packer_provisioner 'setup_apt_current' do
  type 'shell'
  source 'setup_apt_current.sh.erb'
  only azure_builders
  only_if { use_current_repo? }
end

packer_provisioner 'setup_apt_stable' do
  type 'shell'
  source 'setup_apt_current.sh.erb'
  only azure_builders
  not_if { use_current_repo? }
end

packer_provisioner 'install_marketplace_apt' do
  type 'shell'
  source 'install_marketplace_apt.sh.erb'
  only azure_builders
end

packer_provisioner 'setup_yum_current' do
  type 'shell'
  source 'setup_yum_current.sh.erb'
  except azure_builders
  only_if { use_current_repo? }
end

packer_provisioner 'setup_yum_stable' do
  type 'shell'
  source 'setup_yum_stable.sh.erb'
  except azure_builders
  not_if { use_current_repo? }
end

packer_provisioner 'install_marketplace_yum' do
  type 'shell'
  source 'install_marketplace_yum.sh.erb'
  except azure_builders
end

packer_provisioner 'prepare_for_publishing' do
  type 'shell'
  source 'prepare_for_publishing.sh.erb'
end

# TODO: Can probably remove these but they're not hurting anything
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

# Images that should have been built are saved to the node object for later smoke testing
node.normal['marketplace_image']['published_images'] = enabled_image_names
