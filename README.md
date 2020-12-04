Team and repository tags
========================

[![Team and repository tags](https://governance.openstack.org/tc/badges/puppet-heat.svg)](https://governance.openstack.org/tc/reference/tags/index.html)

<!-- Change things from this point on -->

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
8. [Release Notes - Release notes for the project](#release-notes)
9. [Repository - The project source code repository](#repository)

Overview
--------

The heat module is part of [OpenStack](https://opendev.org/openstack), an effort by the
OpenStack infrastructure team to provide continuous integration testing and code review for
OpenStack and OpenStack community projects as part of the core software. The module itself
is used to flexibly configure and manage the orchestration service for OpenStack.

Module Description
------------------

The heat module is an attempt to make Puppet capable of managing the entirety of heat.

Setup
-----

**What the heat module affects**

* [Heat](https://docs.openstack.org/heat/latest/), the orchestration service for OpenStack

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
class { 'heat':
  default_transport_url => 'rabbit://heat:an_even_bigger_secret@127.0.0.1:5672/heat',
  database_connection   => 'mysql+pymysql://heat:a_big_secret@127.0.0.1/heat?charset=utf8',
  keystone_password     => 'a_big_secret',
}

class { 'heat::api': }

class { 'heat::engine':
  auth_encryption_key => '1234567890AZERTYUIOPMLKJHGFDSQ12',
}

class { 'heat::api_cfn': }
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

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://docs.openstack.org/puppet-openstack-guide/latest/

Contributors
------------

* https://github.com/openstack/puppet-heat/graphs/contributors

Release Notes
-------------

* https://docs.openstack.org/releasenotes/puppet-heat

Repository
----------

* https://opendev.org/openstack/puppet-heat
