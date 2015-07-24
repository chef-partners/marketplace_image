# marketplace_image

A cookbook for building and publishing images to various cloud marketplaces

## Supported Platforms

CentOS

## Supported Marketplaces

AWS

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['marketplace_image']['platform']</tt></td>
    <td>String</td>
    <td>The cloud platform to run on</td>
    <td><tt>aws</tt></td>
  </tr>
  <tr>
    <td><tt>['marketplace_image']['role']</tt></td>
    <td>String</td>
    <td>Which role to build</td>
    <td><tt>server</tt></td>
  </tr>
  <tr>
    <td><tt>['marketplace_image']['chef_server_version']</tt></td>
    <td>String</td>
    <td>Which version of the Chef server package to install</td>
    <td><tt>latest</tt></td>
  </tr>
  <tr>
    <td><tt>['marketplace_image']['reporting_version']</tt></td>
    <td>String</td>
    <td>Which version of the Opscode Reporting package to install</td>
    <td><tt>latest</tt></td>
  </tr>
  <tr>
    <td><tt>['marketplace_image']['manage_version']</tt></td>
    <td>String</td>
    <td>Which version of the Chef Manage package to install</td>
    <td><tt>latest</tt></td>
  </tr>
  <tr>
    <td><tt>['marketplace_image']['analytics_version']</tt></td>
    <td>String</td>
    <td>Which version of the Chef Analytics package to install</td>
    <td><tt>latest</tt></td>
  </tr>
  <tr>
    <td><tt>['marketplace_image']['analytics_version']</tt></td>
    <td>String</td>
    <td>The license count for the Chef server</td>
    <td><tt>5</tt></td>
  </tr>
  <tr>
    <td><tt>['marketplace_image']['support_email']</tt></td>
    <td>String</td>
    <td>Unique email for support requests</td>
    <td><tt>aws@chef.io</tt></td>
  </tr>
  <tr>
    <td><tt>['marketplace_image']['aws']['origin_ami']</tt></td>
    <td>String</td>
    <td>The base AMI to build on top of</td>
    <td><tt>ami-d9e61db2</tt></td>
  </tr>
  <tr>
    <td><tt>['marketplace_image']['aws']['server_products']</tt></td>
    <td>Array<Hash></td>
    <td>An Array of Server products hashes</td>
    <td><tt>[{'node_count' => 5, 'product_code' => 'dzsysio0zch27uban3y1c6wh7'}]</tt></td>
  </tr>
</table>

## Usage

Set the path to the marketplace_builder ssh key in your environment

```shell
export MARKETPLACE_BUILDER_SSH_KEY_PATH=~/.ssh/marketplace_builder.pem
```

### Testing

Run the kitchen suite for the platform and role you want to test

```shell
kitchen test chef-server-aws-centos-66
kitchen test analytics-aws-centos-66
```

### Publishing

run build rake task for the platform and role you want to test

```shell
bundle exec rake publish_aws_analytics
bundle exec rake publish_aws_server
```

## License and Authors

Author:: Chef Partner Engineering (<partnereng@chef.io>)
