# marketplace_image

A cookbook for building and publishing images to various cloud marketplaces

## Supported Platforms

Ubuntu 14.04

## Supported Marketplaces

AWS
Azure
Google Compute

## Configuration

The `marketplace_image` cookbook is an attribute driven cookbook that iterates
over "builder definitions" that are configured via attributes.  Builder
definitions are essentially hashes that conform to the following standard:

```ruby
{
  'name' => "unique_builder_name_as_a_string",
  'builder_options' => {
    'key' => 'value',
    'pairs' => 'specific'
    'to' => 'the',
    'packer' => 'driver'
  },
  'marketplace_config_options' => {
    'key' => 'value',
    'pairs' => 'specific'
    'to' => 'the',
    'marketplace' => 'images',
    'desired' => 'config'
  }
}

# Example:

{
  'name' => "gce_example",
  'builder_options' => {
    'type' => 'googlecompute',
    'account_file' => node['marketplace_image']['gce']['account_file'],
    'project_id' => 'chef-marketplace-dev',
    'source_image' => 'centos-7-v20160126',
    'zone' => 'us-central1-a',
    'ssh_username' => 'marketplace'
  },
  'marketplace_config_options' => {
    'role' => 'aio',
    'platform' => 'gce',
    'support_email' => 'cloud-marketplaces@chef.io',
    'reporting_cron_enabled' => true,
    'doc_url' => 'https://docs.chef.io/google_marketplace.html',
    'disable_outbound_traffic' => false,
    'license_count' => 25,
    'license_type' => 'fixed',
    'free_node_count' => 5
  }
}
```

## Publishing

Run the kitchen suite for the products that you wish to build, eg:

```shell
kitchen converge aws-all-publish
```

## License and Authors

Author:: Chef Partner Engineering (<partnereng@chef.io>)
