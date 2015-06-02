# marketplace_image-cookbook

A cookbook for building and publishing Chef Server images to various cloud marketplaces

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
    <td><tt>['marketplace_image']['something']</tt></td>
    <td>String</td>
    <td>The value of something</td>
    <td><tt>wicked this way comes</tt></td>
  </tr>
</table>

## Usage

### marketplace_image::default

Include `marketplace_image` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[marketplace_image::default]"
  ]
}
```

## License and Authors

Author:: Chef Partner Engineering (<partnereng@chef.io>)
