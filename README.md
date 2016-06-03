puppet-heat
=============

#### Table of Contents

1. [Overview - What is the heat module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with heat](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)

Overview
--------

The heat module is part of [OpenStack](https://github.com/openstack), an effort by the
OpenStack infrastructure team to provice continuous integration testing and code review for
OpenStack and OpenStack community projects as part of the core software. The module itself
is used to flexibly configure and manage the orchestration service for OpenStack.

Module Description
------------------

The heat module is an attempt to make Puppet capable of managing the entirety of heat.

Setup
-----

**What the heat module affects**

* [Heat](https://wiki.openstack.org/wiki/Heat), the orchestration service for OpenStack

### Installing heat

    puppet module install openstack/heat

### Beginning with heat

To utilize the heat module's functionality you will need to declare multiple resources.
The following is a modified excerpt from the [openstack module](httpd://github.com/stackforge/puppet-openstack).
This is not an exhaustive list of all the components needed. We recommend that you consult and understand the
[openstack module](https://github.com/stackforge/puppet-openstack) and the [core openstack](http://docs.openstack.org)
documentation to assist you in understanding the available deployment options.

```puppet
# enable heat resources
class { '::heat':
  rabbit_userid       => 'heat',
  rabbit_password     => 'an_even_bigger_secret',
  rabbit_host         => '127.0.0.1',
  database_connection => 'mysql://heat:a_big_secret@127.0.0.1/heat?charset=utf8',
  identity_uri        => 'http://127.0.0.1:35357/',
  keystone_password   => 'a_big_secret',
}

class { '::heat::api': }

class { '::heat::engine':
  auth_encryption_key => '1234567890AZERTYUIOPMLKJHGFDSQ12',
}

class { '::heat::api_cloudwatch': }

class { '::heat::api_cfn': }
```

Implementation
--------------

### puppet-heat

heat is a combination of Puppet manifests and Ruby code to deliver configuration and
extra functionality through types and providers.

### Types

#### heat_config

The `heat_config` provider is a children of the ini_setting provider. It allows one to write an entry in the `/etc/heat/heat.conf` file.

```puppet
heat_config { 'DEFAULT/enable_stack_adopt' :
  value => True,
}
```

This will write `enable_stack_adopt=True` in the `[DEFAULT]` section.

##### name

Section/setting name to manage from `heat.conf`

##### value

The value of the setting to be defined.

##### secret

Whether to hide the value from Puppet logs. Defaults to `false`.

##### ensure_absent_val

If value is equal to ensure_absent_val then the resource will behave as if `ensure => absent` was specified. Defaults to `<SERVICE DEFAULT>`

Limitations
-----------

None

Beaker-Rspec
------------

This module has beaker-rspec tests

To run:

```shell
bundle install
bundle exec rspec spec/acceptance
```

Development
-----------

Developer documentation for the entire puppet-openstack project.

* http://docs.openstack.org/developer/puppet-openstack-guide/

Contributors
------------

* https://github.com/openstack/puppet-heat/graphs/contributors
