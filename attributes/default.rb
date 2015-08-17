default['marketplace_image']['role'] = 'server'
default['marketplace_image']['platform'] = 'aws'
default['marketplace_image']['default_user'] = 'ec2-user'
default['marketplace_image']['support_email'] = 'aws@chef.io'
default['marketplace_image']['reporting_cron'] = true
default['marketplace_image']['publish'] = false
default['marketplace_image']['disable_outbound_traffic'] = false
default['marketplace_image']['license_count'] = 5
default['marketplace_image']['doc_url'] = 'https://docs.chef.io/aws_marketplace.html'

%w(base extras plus updates).each do |repo|
  default['yum'][repo]['enabled'] = true
  default['yum'][repo]['managed'] = true
end
