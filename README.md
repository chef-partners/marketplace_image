# marketplace_image

`marketplace_image` is a Chef cookbook for building and publishing images to
various cloud marketplaces

## All The Things

1. [Supported Platforms](#supported-platforms)
1. [Supported Marketplaces](#supported-marketplaces)
1. [Release Process](#release-process)
  * [Configure Image Definitions](#configure-image-definitions)
  * [Configure Builder Credentials](#configure-builder-credentials)
  * [Build the Images](#build-marketplace-images)
  * [Test the Images](#test-marketplace-images)
  * [Release Marketplace Images](#release-marketplace-images)
    * [AWS Release](#aws-release)
    * [Azure Release](#azure-release)

## Supported Platforms

The `marketplace_image` cookbook has support for the following platforms:

* Ubuntu 14.04

## Supported Marketplaces

The `marketplace_image` cookbook has support for the following cloud marketplaces:

* AWS
* Azure
* Google Compute

### Release Process

Currently there is no scheduled release process for new marketplace images.
New images are usually released for public marketplaces when one or more Chef
Server, Chef Compliance, or add-on packages are released. Assuming that no
bugs are found during manual acceptance testing, the release process can
usually be done by one person in a day.

#### Configure Image Definitions

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

Attributes for all builders should exist in `attributes` directory with a named
entry for each cloud.

#### Configure Builder Credentials

We configure Packer with the right cloud credentials via a data_bag with a keyed
hash for each cloud. If you wish to run these builders you'll need to create a
`data_bags/marketplace_image` directory and populate it with a
`publishing_credentials.json` file with the cloud specific credentials, ie:

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
      "management_certificate": "MIIKDAIXXXXXXX....."
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

The contents of this file can be found in lastpass with the name
_marketplace builder credentials_ and the data_bag should _never_ be committed into
source control.

## Build Marketplace Images

Test Kitchen has several suites for publishing different combinations of images.

If you're targeting a specific release for a cloud and/or product set you'll
probably want to use a targeted combination.

Run kitchen list to view all the release targets:

```shell
kitchen list
```

Run the kitchen suite for the products that you wish to build, eg:

```shell
kitchen converge aws-all-publish
```

## Test Marketplace Images

Currently there is no automated acceptance testing of marketplace images.
In general what we've done is launch one of more of the newly created images
and follow the setup [AWS](docs.chef.io/aws_marketplace.html) or
[Azure](https://docs.chef.io/azure_portal.html#azure-marketplace) setup
documentation to make sure that the user can login and start using the software.

If testing the Chef Sever AIO products you'll want to run `chef-server-ctl test`
to verify that all the Chef Server endpoints are functioning and verify that
the events made it into Analytics.

For Chef Compliance you might want to try scanning an additional AWS node.

## Release Marketplace Images

After the images have been built there are several manual steps that must be
done to release the images in their respective marketplaces.

### AWS Release

After the images have been built you'll need to run them through the AWS
Marketplace security scanner.

1. Log into into the [AWS Marketplace](https://aws.amazon.com/marketplace/management/manage-products/?#/manage-amis.unshared) using the 'aws-marketplace' credentials in lastpass.

1. Share the AMI's with with Amazon by selecting the AMI's that you've just
  produced and click the yellow share button.

1. Wait for the scanning status to be succcessful.

1. Update the AMI ID's in the product load form(s) for the marketplace you're
  updating. You can find the load forms in the Engineering > Marketplace
  folder on drive.

1. Upload the new load forms in the [AWS Marketplace portal](https://aws.amazon.com/marketplace/management/product-load/).

1. Email <aws-marketplace-seller-ops@amazon.com> to notify them of the changes
  and that that you'd like a new release done. Generally you'll hear back from
  them within 24 hours and you'll have the image published in a few days. The
  IC Marketplace can take upwards of 2 months to become available.

### Azure Release

After you've built Azure images you'll need to create a shared access signature,
share the image blobs with Azure and update the products with a new revision.

1. Download and configure the azure cli tools. If you need access to the
  the Azure publishing account you'll need to speak with IT.

1. Determine the primary storage account key

  ```shell
azure login
azure config mode asm
azure storage account keys list ampimages
  ```

1. Create a shared access signiture that is valid from yesterday to a week from
  today.

  ```shell
azure storage container sas create -a ampimages -k <primary storage account key> --start `date -u -v -1d "+%FT%TZ"` --expiry `date -u -v +8d "+%FT%TZ"` --container images --permissions rl
  ```

1. Log in to the [Azure Portal](https://portal.azure.com/) and navigate to the
  ampimages storage account image blobs. I know, easier said than done.

1. Copy the blob URLs for each of the images that you just created to a separate
  document.

1. Append the shared access signature to each image blob, eg:
  `https://ampimages.blob.core.windows.net/images/YOUR_NEW_IMAGES.vhd?<shared access signature>`

1. Login to the [Azure Publishing Portal](https://publish.windowsazure.com) using
  the 'azurestore' credentials in lastpass.

1. For each SKU and license pack add a new VM image version with a your blob link.

1. On the publish tab push to staging.

## License and Authors

Author:: Chef Partner Engineering (<partnereng@chef.io>)
