# znapzend

master branch: [![Build Status](https://secure.travis-ci.org/millerjl1701/millerjl1701-znapzend.png?branch=master)](http://travis-ci.org/millerjl1701/millerjl1701-znapzend)

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
1. [Setup - The basics of getting started with znapzend](#setup)
    * [What znapzend affects](#what-znapzend-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with znapzend](#beginning-with-znapzend)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Module Description

This module installs, configures, and manages the znapzend service on CentOS 6 and 7. For znapzend to function properly, zfs needs to be installed and zpools with appropriate zfs file systems need to be created. 

This module does not manage zfs installation. For this please consider using the [bodgit/zfs](https://forge.puppet.com/bodgit/zfs) puppet module.

This module does not manage creation of zfs file systems or zpools. Puppet provides zfs and zpool resource types which could be used for management of these resources. 

The documentation for znapzend can be found in the code repository: [https://github.com/oetiker/znapzend](https://github.com/oetiker/znapzend). The methods for installation of znapzend in this module mirror the methods documented in the repository; however, it is possible to change what is installed in for prerequisites if needed. For example, if instead of installing perl-core as the documentation states, one could pass an array of perl RPMs instead for a smaller installation footprint. The znapzend code supports other operating systems; however, support in this module for those other opererating systems is not included (pull requests are welcome) at this time.

Configuration of znapzend backup plans may be managed using the either the import define type or imports class. Management of the backup plans uses configuration files and the `znapzendzetup import` command to write the backup plan into the zfs file system properties for the znapzend service to use. If you would prefer to manage each zfs file system property for znapzend directly instead of using the method of import provided here, consider using either the [ggrant/znapzend](https://forge.puppet.com/ggrant/znapzend) or the [cais/znapzend](https://forge.puppet.com/caius/znapzend) puppet module instead.

Note: no validation of the znapzend backup plans is made in this module. If invalid parameters are passed to the template, it will fail to be imported by the `znapzendzetup` command.

## Setup

### What znapzend affects

* Yumrepo: epel via the epel class (enabled by default, but may be disabled with the manage_epel parameter)
* Packages: gcc, gcc-g++ (enabled by default, but may be disabled with the manage_gcc parameter)
* Package: mbuffer (enabled by default, but may be disabled with the manage_mbuffer parameter)
* Package: perl-core (enabled by default, but may be disagled with the manage_perl parameter)
* File: /usr/local/src/znapzend-_versionnumber_ Extracted archive location for building the binaries. Archive extraction may be targeted to a different location if desired.
* File: /opt/znapzend-_versionnumber_ Location for installation which may be set to a different location if desired.
* File: /usr/local/bin/znapzend Link to the appropriate binary version. Link location can be placed in a different directory if desired.
* File: /usr/local/bin/znapzendzetup Link to the approriate binary version. Link location can be placed in a different directory if desired. 
* File: /usr/local/bin/znapzendztatz Link to the appropriate binary version. Link location can be placed in a different directory if desired.
* File: /etc/default/znapzend
* File: /etc/znapzend/configs Directory for where backup plan configuration files are placed. A different location may be used if needed.
* File: /etc/init.d/znapzend (CentOS 6)
* File: /etc/systemd/system/znapzend.service (CentOS 7)
* Service: znapzend

### Setup Requirements

This module relies on other Puppet modules for functionality:
* [camptocamp/systemd](https://forge.puppet.com/camptocamp/systemd) for systemd service management.
* [puppet/archive](https://forge.puppet.com/puppet/archive) for downloading and extracting the source code tar.gz file.
* [puppetlabs/stdlib](https://forge.puppet.com/puppetlabs/stdlib)
* [stahnma/epel](https://forge.puppet.com/stahnma/epel) for setting up the EPEL repository for use.

Since this module installz znapzend from source, there are pieces needed to generate the binaries (gcc, perl-core, etc.). Parameters have been provided to disable these pieces if you already have them declared in different other puppet code to prevent resource duplication.

### Beginning with znapzend

`include znapzend` is all that is needed to install and configure the znapzend service. However, if zfs is not installed or if there are no zfs file systems, the service startup will likely fail.

## Usage

All parameters to the main class may be passed via puppet code or hiera.

Note: the Puppet lookup function will by default create a merged hash for parameter `znapzend::imports::plans`. It is possible to override the merge behavior in your own hiera data; however, this has not been tested and could create unanticipated results.

Another note: no validation of the znapzend backup plans is made in this module. If invalid parameters are passed to the template, it will fail to be imported by the `znapzendzetup` command.

Some futher examples that one could do with the class.

### Use of the class with EPEL repository not being managed

```puppet
  class { 'znapzend':
    manage_epel => false,
  }
```

### Use of the class without managing gcc since it is added to the system by some other means

```puppet
  class { 'znapzend':
    manage_gcc => false,
  }
```

### Use of the class and the defined type for management of a znapzend backup plan for an existing tank/home zfs file system

```puppet
  class { 'znapzend': }
  znapzend::import { 'tank/home':
    options => {
      enabled => 'on',
      src => 'tank/home',
      src_plan => '7d=>1h,30d=>4h,90d=>1d',
      dst_0 => 'backup/home',
      dst_0_plan => '7d=>1h,30d=>4h,90d=>1d,1y=>1w,10y=>1month',
      mbuffer => 'off',
      mbuffer_size => '1G',
      post_znap_cmd => 'off',
      pre_znap_cmd => 'off',
      recursive => 'off',
      tsformat => '%Y-%m-%d-%H%M%S',
    },
  }
```

Note: The name of the resource should be the zfs file system name and not the mount point of the file system.

### Use of hiera and the imports class for creating the same backup plan as in the previous example.

```yaml
---
znapzend::imports::plans:
  'tank/home':
    enabled: 'on'
    src: 'tank/home'
    src_plan: '7d=>1h,30d=>4h,90d=>1d'
    dst_0: 'backup/home'
    dst_0_plan: '7d=>1h,30d=>4h,90d=>1d,1y=>1w,10y=>1month'
    mbuffer: 'off'
    mbuffer_size: '1G'
    post_znap_cmd: 'off'
    pre_znap_cmd: 'off'
    recursive: 'off'
    tsformat: '%Y-%m-%d-%H%M%S'
```

### Use of the class without purging the /etc/znapzend and /etc/znapzend/configs directories

```puppet
  class { 'znapzend':
    plan_confdir_purge => false,
  }
```
Note: if disabling the purge is done, then one would need to remove backup plans no longer in use via some other means from the directory.

## Reference

Generated puppet strings documentation with examples is available from [https://millerjl1701.github.io/millerjl1701-znapzend](https://millerjl1701.github.io/millerjl1701-znapzend).

The puppet strings documentation is also included in the /docs folder.

### Public Classes

* znapzend: Main class which installs, configures, and manages the znapzend service
* znapzend::imports: Class for managing the znapzend backup plans for zfs file systems.

### Private Classes

* znapzend::config: Class which manages the configuration of the znapzend service service scripts.
* znapzend::install: Class which manages the build and installation of znapzend.
* znapzend::prereqs: Class which installs the pieces the documation points to as requirements for building znapzend.
* znapzend::repos: Class which manages the setup of the EPEL repository.
* znapzend::service: Class which manages the znapzend service.

### Public Defined Types

* znapzend::import: Defined type for creation of a znapzend backup plan configuration file and properties on the appropriate zfs file system.

## Limitations

This module installs from source znapzend on CentOS 6 and CentOS 7. It relies on zfs already being installed as well as prior creation of zfs file systems. However, this module makes no attempt at those tasks as there are other existing modules and resources available for use. As an example, please see the acceptance tests written in the spec directory.

This module does not allow for the removal of backup plans from a zfs file system; however, one can overwrite the plans as needed by just changing the parameters fed to the `znapzend::imports::plans` parameter for that zfs file system or the `znapzend::import::options` parameter if using the defined type directly.

Note: no validation of the znapzend backup plans is made in this module. If invalid parameters are passed to the template, it will fail to be imported by the `znapzendzetup` command.

## Development

Please see the [CONTRIBUTING document](CONTRIBUTING.md) for information on how to get started developing code and submit a pull request for this module. While written in an opinionated fashion at the start, over time this can become less and less the case.

### Contributors

To see who is involved with this module, see the [GitHub list of contributors](https://github.com/millerjl1701/millerjl1701-znapzend/graphs/contributors) or the [CONTRIBUTORS document](CONTRIBUTORS).
