source 'https://supermarket.chef.io'

cookbook 'chef-ingredient'
cookbook 'fancy_execute', git: "https://github.com/irvingpop/fancy_execute.git"

metadata

group :integration do
  cookbook 'test', path: './test/fixtures/cookbooks/test'
end
