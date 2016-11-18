# Marketplace Images Developement

This development enviroment loads both the marketplace_images cookbook as well
as cookboooks and code from the omnibus-marketplace project into a development
VM for iteration that does not involve long build times, package publishing, and
spinning up cloud images.

## Getting Started

1. `berks vendor -b ../Berksfile cookbooks

2. `vagrant up`

## Development

All (or most) of the code needed for development is loaded in via the `dev` recipe of the
`marketplace_images` cookbook. Development consists of manually running each of the steps
that take place in the `prepare_for_publishing` phase of the `marketplace_images:_publish`
recipe. These steps are:

1. `chef-marketplace-ctl reconfigure`

2. `chef-marketplace-ctl upgrade`

3. `chef-marketplace-ctl prepare-for-publishing`

4. `chef-marketplace-ctl setup --preconfigure`

It is advised that you take snapshots of the VM after each of these phases to reduce the
development time and allow easy rollback. The `prepare-for-publishing` phase removes all
SSH access from the node and if you log off you'll need to restore from a snapshot.
