source 'https://supermarket.chef.io'

metadata

cookbook 'chef-ingredient',
         git: 'git@github.com:chef-cookbooks/chef-ingredient.git',
         branch: 'upgrade-action'

group :integration do
  cookbook 'test', path: './test/fixtures/cookbooks/test'
end
