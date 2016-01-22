default['marketplace_image']['gce']['public']['aio']['image_id'] = 'ami-1e2c0a74'
default['marketplace_image']['gce']['public']['aio']['products'] = [
  { 'node_count' => 5 }
]

default['marketplace_image']['gce']['public']['compliance']['ami'] = 'ami-dcfcdbb6'
default['marketplace_image']['gce']['public']['compliance']['products'] = [
  { 'node_count' => 5 }
]

default['marketplace_image']['gce']['compliance']['doc_url'] = 'https://docs.chef.io/install_compliance.html#google-marketplace'
default['marketplace_image']['gce']['aio']['doc_url'] = 'https://docs.chef.io/google_marketplace.html'

default['marketplace_image']['gce']['compliance']['support_email'] = 'cloud-marketplaces@chef.io'
default['marketplace_image']['gce']['aio']['support_email'] = 'cloud-marketplaces@chef.io'
