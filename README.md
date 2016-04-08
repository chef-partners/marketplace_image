# marketplace_image

A cookbook for building and publishing images to various cloud marketplaces

## Supported Platforms

Ubuntu 14.04

## Supported Marketplaces

* AWS
* Azure
* Google Compute

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

The packer builders also need to be configured.  Currently this is done via a
data_bag.  If you wish to run these builders you'll need to create a `data_bags/marketplace_image`
directory and populate it with a `publishing_credentials.json` file with the cloud specific
credentials, ie:

```json
{
  "id": "publishing_credentials",
  "azure": {
    "publish_settings": {
      "schema_version": "2.0",
      "publish_method": "AzureServiceManagementAPI",
      "service_management_url": "https://management.core.windows.net",
      "subscription_id": "1XXXXXX-XXXX-XXXX-XXXXXXXXXX",
      "subscription_name": "Partner Engineering",
      "management_certificate": "MIIKDAIXXXXXXX.....",
      "storage_access_key": "7jdH....."
    }
  },
  "gce": {
    "account": {
      "type": "service_account",
      "project_id": "XXXXXXXXXXXXX",
      "private_key_id": "XXXXXXXXXXXXXXXXX",
      "private_key": "-----BEGIN PRIVATE KEY-----\nXXXXXXXXXXXXXXXXXXXXXXXXX=\n-----END PRIVATE KEY-----\n",
      "client_email": "foo@XXXXX.iam.gserviceaccount.com",
      "client_id": "XXXXXXXXXXXXXXXXXXXXX",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://accounts.google.com/o/oauth2/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/XXXXXXXXXXXXXXXXXXXX.iam.gserviceaccount.com"
    }
  },
  "aws": {
    "secret_access_key": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "secret_key_id": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
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
