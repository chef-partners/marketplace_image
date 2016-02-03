require 'chefspec'
require 'chefspec/berkshelf'

describe 'marketplace_image::gce_publisher' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['gce'] = {
        'credentials_file'       => 'test-credentials-file',
        'chef_server'            => 'test-chef-server',
        'validation_client_name' => 'test-validator-name',
        'validation_key'         => 'test-validator-key',
        'ssh_username'           => 'test-username'
      }
      node.set['marketplace_image']['marketplace'] = 'testmarketplace'
      node.set['marketplace_image']['product'] = 'aio'
      node.set['marketplace_image']['gce']['aio']['support_email'] = 'test-support@chef.io'
      node.set['marketplace_image']['gce']['aio']['doc_url'] = 'https://docs.chef.io'
      node.set['marketplace_image']['gce']['testmarketplace']['aio']['products'] = []
      node.set['marketplace_image']['gce']['testmarketplace']['aio']['products'].tap do |x|
        x << { 'node_count' => 5 }
        x << { 'node_count' => 10 }
        x << { 'node_count' => 15 }
      end
    end.converge(described_recipe)
  end

  it 'creates a GCE image for each configured product' do
    time = Time.now.strftime('%Y%m%d')
    expect(chef_run).to create_marketplace_image_gce("chef-aio-testmarketplace-5-#{time}")
    expect(chef_run).to create_marketplace_image_gce("chef-aio-testmarketplace-10-#{time}")
    expect(chef_run).to create_marketplace_image_gce("chef-aio-testmarketplace-15-#{time}")
  end
end
