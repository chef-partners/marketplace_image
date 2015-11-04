source 'https://supermarket.chef.io'

cookbook 'chef-ingredient', github: 'chef-cookbooks/chef-ingredient', branch: 'ryan/compliance'

metadata

group :integration do
  cookbook 'test', path: './test/fixtures/cookbooks/test'
end
