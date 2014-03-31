# puppet-ovirt

[![Build Status](https://travis-ci.org/treydock/puppet-ovirt.png)](https://travis-ci.org/treydock/puppet-ovirt)

The ovirt module lets you manage oVirt Engine and Nodes.

## Compatibility

| Puppet Versions   | < 2.6 | 2.6 | 2.7     | 3.x     |
|:-----------------:|:-----:|:---:|:-------:|:-------:|
| **ovirt 0.0.x** | no    | no  | **yes** | **yes** |


Tested using the following oVirt versions

* 3.3.x

Tested using the following Operating Systems

* CentOS 6.5

## Usage

### Class: ovirt

Installs the oVirt repositories.  This class is included by the *ovirt::engine* and *ovirt::node* classes.

    class { 'ovirt': }

### Class: ovirt::engine

Install and manage ovirt-engine.

The default behavior should match that of the defaults when running *engine-setup*.

    class { 'ovirt::engine':
      admin_password  => 'changeme',
      db_password => 'changeme',
    }

To install ovirt-engine without setting up an ISO domain, using NFS without Gluster

    class { 'ovirt::engine':
      admin_password      => 'changeme',
      db_password         => 'changeme',
      application_mode    => 'virt',
      storage_type        => 'nfs',
      nfs_config_enabled  => false,
    }

### Class: ovirt::node

Install and manage an oVirt node.

    class { 'ovirt::node': }

### Type: vdsm_config

Manage VDSM configuration options.

The **namevar** of the Vdsm_config resources must be form 'SECTION/SETTING'.

An example of setting the management_ip for VDSM.

    vdsm_config { 'addresses/management_ip':
      value => '0.0.0.0',
    }

The example above will add lines like this to /etc/vdsm/vdsm.conf

    [addresses]
    management_ip=0.0.0.0

## Reference

Types:

* [vdsm_config](#type-vdsm_config)

### Type: vdsm_config

This type provides the capability to manage values in */etc/vdsm/vdsm.conf*.

The name is in form of 'section/setting'.

####`ensure`

Can either be `present` or `absent`.  Defaults to `present`.

####`value`

The vdsm_config value to set.

If *ensure* is `present` then value must be defined.

## Development

### Testing

Make sure you have:

* rake
* bundler

Install the necessary gems:

    bundle install

Run the tests from root of the source code:

    bundle exec rake test

You can also run acceptance tests:

    bundle exec rake acceptance

## TODO

* Conditionally manage the different ovirt node firewall openings
* Once puppetlabs-firewall supports physdev ([MODULES-20](https://tickets.puppetlabs.com/browse/MODULES-20)) manage all firewall rules created by ovirt-engine
* Manage yumrepo resources instead of the ovirt-release RPM
