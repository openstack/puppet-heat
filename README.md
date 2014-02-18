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
8. [Release Notes - Notes on the most recent updates to the module](#release-notes)

Overview
--------

The heat module is a part of [Stackforge](https://github.com/stackforge), an effort by the Openstack infrastructure team to provide continuous integration testing and code review for Openstack and Openstack community projects not part of the core software. The module itself is used to flexibly configure and manage the baremetal service for Openstack.

Module Description
------------------

Setup
-----

**What the heat module affects:**

* heat, the orchestration service for Openstack.

Implementation
--------------

### puppet-heat

puppet-heat is a combination of Puppet manifest and ruby code to delivery configuration and extra functionality through types and providers.

Limitations
-----------

The Heat Openstack service depends on a sqlalchemy database. If you are using puppetlabs-mysql to achieve this, there is a parameter called mysql_module that can be used to swap between the two supported versions: 0.9 and 2.2. This is needed because the puppetlabs-mysql module was rewritten and the custom type names have changed between versions.

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://wiki.openstack.org/wiki/Puppet-openstack#Developer_documentation

Contributors
------------

* https://github.com/stackforge/puppet-heat/graphs/contributors

Release Notes
-------------

