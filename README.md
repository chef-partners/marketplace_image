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
  * [Stage Marketplace Images](#stage-marketplace-images)
    * [AWS Staging](#aws-staging)
    * [Azure Staging](#azure-staging)
  * [Test Staged Images](#test-staged-images)
    * [Boot Staged AWS Images](#boot-staged-aws-images)
    * [Boot Staged Azure Images](#boot-staged-azure-images)
  * [Publish Images](#publish-images)
    * [Publish AWS Images](#publish-aws-images)
    * [Publish Azure Images](#publish-azure-images)

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
Server or add-on packages are released. Assuming that no
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
      "subscription_id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
      "subscription_name": "XXXXXXXXXXXXXXXXXXXX",
      "client_id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
      "client_secret": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
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

**This data_bag should never be committed into source control.**

The current data bag item is in the lastpass shared folder `marketplace-images`.

**This data_bag should never be committed into source control.**


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

Note that the kitchen output contains the name and/or location of the built image. Finding the built image in the cloud GUIs can sometimes be more difficult than one would like, so it's worth making a note of these. Example:

```
amazon:

==> Builds finished. The artifacts of successful builds are:
                --> aws_public_automate: AMIs were created:

                us-east-1: ami-358b7a4f
```

and

```
azure:

--> azure_automate_BYOL: Azure.ResourceManagement.VMImage:

StorageAccountLocation: eastusOSDiskUri: https://marketplaceimages.blob.core.windows.net/system/Microsoft.Compute/Images/vhds/Chef_Automate_BYOL-osDisk.88a0957e-f746-4baa-9436-6eeb39bfa859.vhd
OSDiskUriReadOnlySas: https://marketplaceimages.blob.core.windows.net/system/Microsoft.Compute/Images/vhds/Chef_Automate_BYOL-osDisk.88a0957e-f746-4baa-9436-6eeb39bfa859.vhd?se=2017-11-11T18%3A44%3A13Z&sig=LYS1RULmDLYi1f99kSRa5fwmoTSZXDyuZKwxBjQwZDU%3D&sp=r&spr=https%2Chttp&sr=b&sv=2016-05-31TemplateUri: https://marketplaceimages.blob.core.windows.net/system/Microsoft.Compute/Images/vhds/Chef_Automate_BYOL-vmTemplate.88a0957e-f746-4baa-9436-6eeb39bfa859.json
TemplateUriReadOnlySas: https://marketplaceimages.blob.core.windows.net/system/Microsoft.Compute/Images/vhds/Chef_Automate_BYOL-vmTemplate.88a0957e-f746-4baa-9436-6eeb39bfa859.json?se=2017-11-11T18%3A44%3A13Z&sig=mS%2BRNR4Uu6fX6qaKFdd0MuGxtXbUggWFOBL1uu0m2uI%3D&sp=r&spr=https%2Chttp&sr=b&sv=2016-05-31

- execute packer build -parallel=true -only=azure_automate_BYOL /tmp/template.json20171011-1631-tmn9y1
  * ruby_block[cleanup temp file] action run
    - execute the ruby block cleanup temp file
```

## Test Marketplace Images

Currently there is no automated acceptance testing of marketplace images.
In general what we've done is launch one of more of the newly created images
and follow the setup [AWS](https://docs.chef.io/aws_marketplace.html) or
[Azure](https://docs.chef.io/azure_portal.html#azure-marketplace) setup
documentation to make sure that the user can login and start using the software.

If testing the Chef Sever AIO products you'll want to run `chef-server-ctl test`
to verify that all the Chef Server endpoints are functioning and verify that
the events made it into Analytics.

## Stage Marketplace Images

After the images have been built there are several manual steps that must be
done to stage the images in their respective marketplaces.

### AWS Staging

After the images have been built you'll need to run them through the AWS
Marketplace security scanner.

1. Log into the [AWS Marketplace](https://aws.amazon.com/marketplace/management/manage-products/?#/manage-amis.unshared) using the 'aws-marketplace' credentials in lastpass.

1. Share the AMI's with with Amazon by selecting the AMI's that you've just
  produced and click the yellow share button.

1. Wait for the scanning status to be succcessful. (~60 minutes).

1. Update the AMI ID's in the product load form(s) for the marketplace you're
  updating. You can find the load forms in the Engineering > Marketplace
  folder on drive.

1. Upload the new load forms in the [AWS Marketplace portal](https://aws.amazon.com/marketplace/management/product-load/).

1. Email <aws-marketplace-seller-ops@amazon.com> to notify them of the changes
  and that that you'd like a new release done. Generally you'll hear back from
  them within 24 hours and you'll have the image published in a few days. The
  IC Marketplace can take upwards of 2 months to become available. Make sure
  to CC <aws-marketplace@chef.io> so that all stakeholders are in the loop. 

1. Locate the submittal doc in Engineering > Marketplace > Marketplace Image
  Submittal History on drive. Add a new entry for the image and cloud.

1. AWS will announce that the image is staged via email. [Test the image.](test-staged-images) If any
  issues are found, fix them and repeat the process from step one. If no issues
  are found, request that they [publish the image](#publish-aws-images).

1. Make sure you update the submittal history document during each stage.

### Azure Staging

After you've built Azure images you'll need to create a shared access signature,
share the image blobs with Azure and update the products with a new revision.

1. Create the shared access signature with either the [Azure GUI](#azure-gui) or the [Azure command line](#azure-command-line).

1. Log in to the [Azure Portal](https://portal.azure.com/) and navigate to the
  marketplaceimages storage account image blobs. I know, easier said than done.
  You get to skip this step if you saved the image URLs from the kitchen output.

1. Copy the blob URLs for each of the images that you just created to a separate
  document.

1. Append the shared access signature to each image blob, eg:
  `https://marketplaceimages.blob.core.windows.net/system/Microsoft.Compute/Images/<your container>/<your new images>.vhd?<shared access signature>`

1. Login to the [Azure Publishing Portal](https://publish.windowsazure.com) using
  the 'azurestore' credentials in lastpass. Go to Virtual Machines and say yes, you do want to use the new UI.

1. Select your image, e.g. "Chef Automate VM Image" -> SKUs -> select your SKU. (Currently "byol" for the Chef Automate VM Image.)

1. Scroll to the bottom of the page and click on "+ New VM Image".

1. For each SKU and license pack add a new VM image version with a your blob link. To turn our package versions into semver versions, concatenate the version number with the iteration, e.g. 1.6.179-1 becomes 1.6.1791.

1. On the publish tab push to staging.

1. Locate the submittal doc in Engineering > Marketplace > Marketplace Image
  Submittal History on drive. Add a new entry for the image and cloud.

1. Azure will announce that the image is staged via email. [Test the image](#test-staged-images). If any
  issues are found, fix them and repeat the process from step one. If no issues
  are found, request that they [publish the image](#publish-azure-images).

1. Make sure you update the submittal history document during each stage.

#### Azure GUI
1. Login to the Partner Engineering Azure portal.

1. Go to More Services -> Storage Accounts -> marketplaceimages -> Shared access signature.

1. Create a shared access signature that is valid from yesterday to a week from today with Allowed Services = Blob; Allowed Resource Types = container, object, and Allowed Permissions = read, list.

#### Azure command line
(Reference: https://buildazure.com/2017/05/23/azure-cli-2-0-generate-sas-token-for-blob-in-azure-storage/)
(currently untested due to weird; once we test it, it will be the default)

1. Download and configure the [azure cli 2.0 tools](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

1. Determine the primary storage account key

  ```shell
az login
az storage account keys list --resource-group publish-marketplace-images --account-name marketplaceimages
  ```

1. Create a shared access signature that is valid from yesterday to a week from
  today.

  ```shell
az storage blob generate-sas --account-name marketplaceimages --account-key <primary storage account key> --container-name vhds --permissions rl --start `date -u -v -1d "+%FT%TZ"` --expiry `date -u -v +8d "+%FT%TZ"`
  ```
### Test Staged Images
The basic strategy will be

1. Using the staged image, boot an instance ([AWS](#boot-staged-aws-images), [Azure](#boot-staged-azure-images)). It takes 10 minutes or so for automate to become available once the instance itself has been booted.

1. Test the staged image. An incomplete list of tests to run:
   * Login to the instance
     * Verify the correct versions of automate, chef-server, and marketplace have been installed.
     * Run `chef-server-ctl test` to verify the chef-server install.
   * Set up a user and org in automate using biscotti (link is in the MOTD that appears on login to the instance).
   * Set up a compliance profile, bootstrap a node with that profile, and verify that node data and compliance data are displayed correctly in the automate UI.
   * (Amazon) Login to the instance and check the reckoner logs to make sure metering data is being sent.
   * Verify release-specific features.

1. If you find any issues, fix them and repeat the process from step one. If no issues are found, request the cloud provider to [publish the image](#publish-images).

#### Boot Staged AWS Images
Currently, when AWS stages an image, they email us the AMI ID. When you start an instance from that AMI, you will need to assign the [marketplace metering role](https://aws.amazon.com/marketplace/help/buyer-metering-enabled-products?ref=help_ln_sibling#topic2) to the instance. You will also need to put the instance in a security group that is open on ports 22, 443, and 8989.

#### Boot Staged Azure Images
Once Azure has staged an image, they will announce it to us in email. By convention, the name of the staged image is the original image name with "preview" appended to it, e.g. "chef-automate-vm-image-preview". The [omnibus-marketplace repo](https://github.com/chef-partners/omnibus-marketplace) contains a solution template you can use to boot an instance from the preview image:

1. Make sure the `automatearmtest` resource group exists in the Chef Partner Engineering Azure portal.

1. Create a branch of [omnibus-marketplace](https://github.com/chef-partners/omnibus-marketplace) where the `imageProduct` parameter in `arm-templates/automate/mainTemplateParameters.json` is set to the name of the preview image.

1. Push the branch to github.

1. In `arm-templates/automate/mainTemplateParameters.json`, set the value of `baseUrl` to the branch name in github. Push the change.

1. Run `make arm-test` in the `omnibus-marketplace` root directory to boot an instance using our current solutions template from github with the staged image.

1. When you are done with your testing, clean up by removing the `automatearmtest` resource group.

([More details](https://github.com/chef-partners/omnibus-marketplace#azure-solution-template) on working with the solution template.)

### Publish Images
Once you've completed your testing to your satisfaction, you will need to publish your image.

#### Publish AWS Images
Email <aws-marketplace-seller-ops@amazon.com> and let them know the image is ready for publication. Update the submission history.

#### Publish Azure Images
Login to the Azure publishing portal and go to Virtual Machines. The portal will ask if you want to go to its new incarnation; say yes. Go to Chef Automate VM Image -> Status and hit Publish. Update the submission history.

## License and Authors

Author:: Chef Partner Engineering (<partnereng@chef.io>)
