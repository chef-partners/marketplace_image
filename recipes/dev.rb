# this recipe is only meant to be run for development

# write marketplace config
template '/tmp/marketplace.rb' do
  source 'marketplace.rb.erb'
  variables(role: 'automate',
            platform: 'azure',
            user: 'vagrant',
            support_email: 'dev@chef.io',
            doc_url: 'https://chef.io',
            reporting_cron_enabled: true,
            disable_outbound_traffic: false,
            license_count: 25,
            license_type: 'fixed',
            free_node_count: 5)
end

# setup marketplace
bash 'setup_marketplace' do
  # TODO: copied from templates/default/setup_marketplace.sh.erb
  # there doesn't appear to be any way to exectute a template-like
  # thing in Chef
  code <<EOF
set -ex

sudo mkdir -p /etc/chef-marketplace
sudo mkdir -p /etc/opscode
sudo cp /tmp/marketplace.rb /etc/chef-marketplace/
# sudo cp /tmp/chef-server.rb /etc/opscode/
EOF
end

# setup apt repositories
bash 'apt_upgrade' do
  code <<EOF
set -ex

sudo rm -rf /etc/apt/sources.list.d/*chef*
sudo mkdir -p /etc/apt/sources.list.d/
sudo apt-get update
sudo apt-get install apt-transport-https -y
sudo wget -qO - https://downloads.chef.io/packages-chef-io-public.key | sudo apt-key add -
echo "deb https://packages.chef.io/stable-apt trusty main" | sudo tee /etc/apt/sources.list.d/chef-stable.list
sudo apt-get update
sudo apt-get install chef-marketplace -y
EOF
end

# TODO: berks vendor the cookbooks
# by not using berks install here, we end up getting whatever dependency cookbooks that ship
# with the chef-marketplace package that we're using, even if they're way out of date or
# incompatible. The problem with using `berks install/vendor` is that then we'll have to do some
# serious futzing with things to get automatic code loading still working, which is the real goal
# here.
bash 'link_development' do
  code <<EOF
set -ex

mkdir -p /home/vagrant/backup

mv /opt/chef-marketplace/embedded/cookbooks/chef-marketplace /home/vagrant/backup/
ln -s /home/vagrant/omnibus-marketplace/files/chef-marketplace-cookbooks/chef-marketplace /opt/chef-marketplace/embedded/cookbooks/chef-marketplace

mv /opt/chef-marketplace/embedded/service/chef-marketplace-ctl /home/vagrant/backup/
ln -s /home/vagrant/omnibus-marketplace/files/chef-marketplace-ctl-commands /opt/chef-marketplace/embedded/service/chef-marketplace-ctl

mv /opt/chef-marketplace/embedded/lib/ruby/gems/2.2.0/gems/chef-marketplace-0.0.1 /home/vagrant/backup/
ln -s /home/vagrant/omnibus-marketplace/files/chef-marketplace-gem /opt/chef-marketplace/embedded/lib/ruby/gems/2.2.0/gems/chef-marketplace-0.0.1

EOF
end
