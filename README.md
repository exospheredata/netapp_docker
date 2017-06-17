# netapp_docker
### _A cookbook to manage NetApp Docker Volume Plugin deployments_
This cookbook manages installations of the NetApp Docker Volume Plug-in (nDVP) including the creation of configuration files, plug-in installation and dependencies.  The included resources also installs and configures NFS and iSCS services.

For full details on the NetApp Docker Volume Plugin visit the [official documentation](http://netappdvp.readthedocs.io/en/latest/index.html)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Requirements](#requirements)
  - [Platforms](#platforms)
  - [Chef](#chef)
  - [Cookbooks](#cookbooks)
  - [Data bag](#data-bag)
- [Attributes](#attributes)
  - [Docker Configuration](#docker-configuration)
  - [Docker Volume Plugin attributes](#docker-volume-plugin-attributes)
  - [ONTAP attributes](#ontap-attributes)
- [Custom Resource](#custom-resource)
  - [netapp_docker_ontap_plugin](#netapp_docker_ontap_plugin)
- [Usage](#usage)
  - [default](#default)
  - [ontap](#ontap)
- [Upload to Chef Server](#upload-to-chef-server)
- [Matchers/Helpers](#matchershelpers)
  - [Matchers](#matchers)
  - [Helpers](#helpers)
- [Cookbook Testing](#cookbook-testing)
  - [Before you begin](#before-you-begin)
  - [Data_bags for Test-Kitchen](#data_bags-for-test-kitchen)
  - [Rakefile and Tasks](#rakefile-and-tasks)
  - [Chefspec and Test-Kitchen](#chefspec-and-test-kitchen)
  - [Test Cookbook (netapp_docker_test):](#test-cookbook-netapp_docker_test)
- [Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.](#copyright-2017-exosphere-data-llc-all-rights-reserved)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Requirements

### Platforms

###### Host OS:

- Debian
- Ubuntu, 14.04+ if not using iSCSI multipathing, 15.10+ with iSCSI multipathing.
- CentOS, 7.0+
- RHEL, 7.0+

###### Storage Systems:

- ONTAP: 8.3 or greater
- SolidFire: ElementOS 7 or greater
- E-Series: Santricity

### Chef

- 12.5+

### Cookbooks

- docker, >= 2.15.6

### Data bag

- N/A

## Attributes

A list of available node attributes.  Required attributes marked in **bold**.  All other attributes can be excluded.

### Docker Configuration

| Attribute | Type | Description | Default |
| ------------- |-------------|-------------|-------------|
| `node['docker']['members']` | String,Array | Adds users to the local `docker` group to provide access to docker commands without requiring sudo access. | nil |

### Docker Volume Plugin attributes

| Attribute | Type | Description | Default |
| ------------- |-------------|-------------|-------------|
| **`node['netapp_docker']['config']['ndvp_config']`** | String | Defines the configuration file name with `.json` extension for the Plugin installation and the name to which the plugin will be registered.  | 'netapp' |
| **`node['netapp_docker']['config']['config_type']`** | String | Determines the type of plug=in configuration.  Supported values are 'ontap-nas' or 'ontap-san' | 'ontap-nas' |
| **`node['netapp_docker']['config']['plugin_version']`** | String | Determines the specific version of the plugin to install.  Defaults to "latest" | 'latest' |

### ONTAP attributes

#### Required attributes

| Attribute | Type | Description | Default |
| ------------- |-------------|-------------|-------------|
| **`node['netapp_docker']['config']['ontap_mgmt_ip']`** | String | IP or Hostname for the NetApp Storage Virtual Machine Manaegment (SVM) LIF | nil |
| **`node['netapp_docker']['config']['ontap_data_ip']`** | String | IP or Hostname for the NetApp Storage Virtual Machine NFS or iSCSI LIF | nil |
| **`node['netapp_docker']['config']['svm']`** | String | NetApp Storage Virtual Machine name | nil |
| **`node['netapp_docker']['config']['aggregate']`** | String | Assigned NetApp Aggregate to use for provisioning. Requires that the aggregate be listed in the SVM aggr_list  | nil |
| **`node['netapp_docker']['config']['username']`** | String | Storage Virtual Machine username | nil |
| **`node['netapp_docker']['config']['password']`** | String | Storage Virtual Machine user password | nil |
| **`node['netapp_docker']['config']['prefix']`** | String | Sets the NetApp volume name prefix.  Defaults to the plug-in name| nil |

#### Optional Configuration Default attributes

| Attribute | Type | Description | Default |
| ------------- |-------------|-------------|-------------|
| `node['netapp_docker']['config']['defaults']['size']` | String | Sets the default volume size for each docker volume | nil |
| `node['netapp_docker']['config']['defaults']['space_reserve']` | String | Space reservation mode; "none" (thin provisioned) or "volume" (thick) | nil |
| `node['netapp_docker']['config']['defaults']['snapshot_policy']` | String | Snapshot policy to use, default is "none" | nil |
| `node['netapp_docker']['config']['defaults']['split_on_clone']` | Boolean | Split a clone from its parent upon creation, defaults to "false" | nil |

#### only valid for NAS configurations

| Attribute | Type | Description | Default |
| ------------- |-------------|-------------|-------------|
| `node['netapp_docker']['config']['nfs_mount_options']` | String | Fine grained control of NFS mount options; defaults to "-o nfsvers=3" | nil |
| `node['netapp_docker']['config']['defaults']['export']` | String | NAS option for the NFS export policy to use, defaults to "default" | nil |
| `node['netapp_docker']['config']['defaults']['unix_permissions']` | String | NAS option for provisioned NFS volumes, defaults to "777" | nil |
| `node['netapp_docker']['config']['defaults']['snapshot_dir']` | String | NAS option for access to the .snapshot directory, defaults to "false" | nil |
| `node['netapp_docker']['config']['defaults']['security_style']` | String | NAS option for access to the provisioned NFS volume, defaults to "unix" | nil |

## Custom Resource

### netapp_docker_ontap_plugin

Manages the configuration and installation of a NetApp Docker Volume Plugin configuration for a host.

**default_action :config**

#### Action :config
---
Generates a configuration file based on supplied attributes

##### Properties
_NOTE: properties in bold are required_

###### Global Configuration properties
_These options will be set for every Docker Volume created by the plugin and are not tuneable_

| Property | Type | Description |
| ------------- |-------------|-------------|
| **`config_name`** | String | Name Attribute.  Sets the Plugin installation name.  Defaults to 'netapp' |
| `ndvp_config` | String | Sets the configuration file name with `.json` extension.  All files will be created in the `/etc/netappdvp/` directory. Defaults to 'config.json' |
| `config_type` | String | Determines the type of plug=in configuration.  Supported values are 'ontap-nas' or 'ontap-san'.  Default value is 'ontap-nas'. |
| **`ontap_mgmt_ip`** | String | IP or Hostname for the NetApp Storage Virtual Machine Manaegment (SVM) LIF |
| **`ontap_data_ip`** | String | IP or Hostname for the NetApp Storage Virtual Machine NFS or iSCSI LIF |
| **`svm`** | String | NetApp Storage Virtual Machine name |
| **`username`** | String | Assigned NetApp Aggregate to use for provisioning. Requires that the aggregate be listed in the SVM aggr_list |
| **`password`** | String | Storage Virtual Machine username |
| **`aggregate`** | String | Storage Virtual Machine user password |
| `prefix` | String, nil | Sets the NetApp volume name prefix.  Defaults to the plug-in name |
| `nfs_mount_options` | String, nil | Fine grained control of NFS mount options; defaults to "-o nfsvers=3" |

###### Optional Defaults
_If not configured, these settings will not be added to the configuration file and the plugin will use the version defaults_

| Property | Type | Description |
| ------------- |-------------|-------------|
| `default_size` | String, nil | Sets the default volume size for each docker volume |
| `default_space_reserve` | String, nil | Space reservation mode; "none" (thin provisioned) or "volume" (thick) |
| `default_snapshot_policy` | String, nil | Snapshot policy to use, default is "none" |
| `default_split_on_clone` | String, nil | Split a clone from its parent upon creation, defaults to "false" |
| `default_export` | String, nil | NAS option for the NFS export policy to use, defaults to "default" |
| `default_unix_permissions` | String, nil | NAS option for provisioned NFS volumes, defaults to "777" |
| `default_snapshot_dir` | TrueClass,FalseClass | NAS option for access to the .snapshot directory, defaults to "false" |
| `default_security_style` | String, nil | NAS option for access to the provisioned NFS volume, defaults to "unix" |

##### Examples
###### New minimal ontap-nas
_NetApp Docker Volume Plugin configuration using the ontap-nas plugin_
```ruby
netapp_docker_ontap_plugin 'netapp' do
  ontap_mgmt_ip '192.168.100.184'
  ontap_data_ip '192.168.100.185' # nfs lif
  svm 'svm_docker'
  username 'vsadmin'
  password 'netapp123'
  aggregate 'aggr1'
  action :config
end

```

###### New minimal ontap-san
_NetApp Docker Volume Plugin configuration using the ontap-san plugin with a default size of 100g for each new volume_
```ruby
netapp_docker_ontap_plugin 'netapp' do
  ontap_mgmt_ip '192.168.100.184'
  ontap_data_ip '192.168.100.186' # iscsi lif
  svm 'svm_docker'
  username 'vsadmin'
  password 'netapp123'
  aggregate 'aggr1'
  default_size '100g'
  action :config
end

```

#### Action :install
---
Downloads and installs the specified NetApp Docker Volume Plugin (nDVP) based on the suppied configuration file. Installs prerequisites for the nDVP configuration.

_**NOTE**_: This action requires that the configuration file supplied exist on the local node's file system in the /etc/netappdvp/ directory

_**NOTE**_: When installing, the cookbook will determine the `config_type`.  If 'ontap-nas', then the solution will verify and install NFS client services on the host.  If 'ontap-san', then the solution will veriify and install iSCSI and Multi-path services on the host.  More details about what is added can be found here: [official documentation](http://netappdvp.readthedocs.io/en/latest/index.html)

##### Properties
_NOTE: properties in bold are required_

###### Global Configuration properties
_These options will be set for every Docker Volume created by the plugin and are not tuneable_

| Property | Type | Description |
| ------------- |-------------|-------------|
| **`config_name`** | String | Name Attribute.  Sets the Plugin installation name.  Defaults to 'netapp' |
| `ndvp_config` | String | Sets the configuration file name with `.json` extension.  All files will be created in the `/etc/netappdvp/` directory.  Defaults to 'config.json' |
| `config_type` | String | Determines the type of plug=in configuration.  Supported values are 'ontap-nas' or 'ontap-san'.  Default value is 'ontap-nas'. |
| **`plugin_version`** | String | Determines the version of the plugin to download and install.  Default is "latest" |

##### Examples
###### New plugin installation and configuration.
_installation and configuration of NetApp Docker Volume Plugin using the ontap-nas plugin_
```ruby
netapp_docker_ontap_plugin 'netapp' do
  ontap_mgmt_ip '192.168.100.184'
  ontap_data_ip '192.168.100.185' # nfs lif
  svm 'svm_docker'
  username 'vsadmin'
  password 'netapp123'
  aggregate 'aggr1'
  action [:config, :install]
end

```
###### New plugin installation with existing configuration file.
_installation and configuration of NetApp Docker Volume Plugin using the ontap-nas plugin_
```ruby
netapp_docker_ontap_plugin 'netapp' do
  action :install
end

```

###### Custom plugin installation name
_installs the specified version of NetApp Docker Volume Plugin as a custom name_
```ruby
netapp_docker_ontap_plugin 'mynetapp01' do
  ndvp_config 'mynetapp01_ndvp.json'
  plugin_version 'v17.04.0'
  action [:config, :install]
end

```

#### Action :enable
---
Enables a registered and installed NetApp Docker Volume Plugin instance

_Note: The action :install will automatically enable the newly installed plugin.  It will also ensure that on each run, that the plugin is installed and enabled_

##### Properties
_NOTE: properties in bold are required_

###### Global Configuration properties
_These options will be set for every Docker Volume created by the plugin and are not tuneable_

| Property | Type | Description |
| ------------- |-------------|-------------|
| **`config_name`** | String | Name Attribute.  Sets the Plugin installation name.  Defaults to 'netapp' |

##### Examples
###### Enable an existing NetApp Docker Volume Plugin installation.
```ruby
netapp_docker_ontap_plugin 'netapp' do
  action [:enable]
end

```

#### Action :disable
---
Disables a registered and installed NetApp Docker Volume Plugin instance

_**Note: The plugin can only be disabled if not in use.**_

##### Properties
_NOTE: properties in bold are required_

###### Global Configuration properties
_These options will be set for every Docker Volume created by the plugin and are not tuneable_

| Property | Type | Description |
| ------------- |-------------|-------------|
| **`config_name`** | String | Name Attribute.  Sets the Plugin installation name.  Defaults to 'netapp' |

##### Examples
###### Disable an existing NetApp Docker Volume Plugin installation.
```ruby
netapp_docker_ontap_plugin 'netapp' do
  action [:disable]
end

```

#### Action :delete
---
Disable and delete an existing installation of NetApp Docker Volume Plugin.

_Note: This action will be implemented in a future release_

##### Properties
_Note: This action will be implemented in a future release_

##### Examples
_Note: This action will be implemented in a future release_

## Usage
### default

This is an empty recipe and should _not_ be used

### ontap

This recipe will create a new configuration for the NetApp Docker Volume Plug-in and install the plugin into a docker configuration.  If docker has not been installed, the recipe will perform the installation automatically.  All pre-requisite features and services for NFS and iSCSI will be installed depending on the `config_type` selected - 'ontap-nas' or 'ontap-san'

## Upload to Chef Server
This cookbook should be included in each organization of your CHEF environment.  When importing, leverage Berkshelf:

`berks upload`

_NOTE:_ use the --no-ssl-verify switch if the CHEF server in question has a self-signed SSL certificate.

_NOTE:_ the `--except test` switch will prevent Berkshelf from uploading the included test cookbook

`berks upload --no-ssl-verify --except test`

## Matchers/Helpers

### Matchers
_Note: Matchers should always be created in `libraries/matchers.rb` and used for validating calls to LWRP_

- install_netapp_docker_ontap_plugin(resource_name)
- config_netapp_docker_ontap_plugin(resource_name)

### Helpers

There are no included helpers at this time

## Cookbook Testing

### Before you begin
Setup your testing and ensure all dependencies are installed.  Open a terminal windows and execute:

```ruby
gem install bundler
bundle install
berks install
```

### Data_bags for Test-Kitchen

This cookbook requires the use of a data_bag for setting certain values.  Local JSON version need to be stored in the directory structure as indicated below:

```
├── chef-repo/
│   ├── cookbooks
│   │   ├── netapp_docker
│   │   │   ├── .kitchen.yml
│   ├── data_bags
│   │   ├── data_bag_name
│   │   │   ├── data_bag_item.json

```

**Note**: Storing local testing versions of the data_bags at the root of your repo is considered best practice.  This ensures that you only need to maintain a single copy while protecting the cookbook from being accientally committed with the data_bag.  However, if you must change this location, then update the following key in the .kitchen.yml file.

```
data_bags_path: "../../data_bags/"
```

### Rakefile and Tasks
This repo includes a **Rakefile** for common tasks

| Task Command | Description |
| ------------- |-------------|
| **rake** | Run Style, Foodcritic, Maintainers, and Unit Tests |
| **rake style** | Run all style checks |
| **rake style:chef** | Run Chef style checks |
| **rake style:ruby** | Run Ruby style checks |
| **rake style:ruby:auto_correct** | Auto-correct RuboCop offenses |
| **rake unit** | Run ChefSpec examples |
| **rake integration** | Run all kitchen suites |
| **rake integration:kitchen:demo-centos-72** | Run demo-centos-72 test instance |
| **rake integration:kitchen:demo-ubuntu-1604** | Run demo-ubuntu-1604 test instance |
| **rake maintainers:generate** | Generate MarkDown version of MAINTAINERS file |

### Chefspec and Test-Kitchen
_**NOTE:**_ Execution of Test-Kitchen requires that you first make a copy of .kitchen.yml and save in the root of the repo as .kitchen.local.yml.  Within this file, you will need to edit the attributes to match your actual environment.  The installation and configuration of NetApp Docker Volume Plugin will fail if the system is unable to log into a valid storage controller.

1. `bundle install`: Installs and pulls all ruby gems dependencies from the Gemfile.

2. `berks install`: Installs all cookbook dependencies based on the [Berksfile](Berksfile) and the [metadata.rb](metadata.rb)

3. `rake`: This will run all of the local tests - syntax, lint, unit, and maintainers file.
4. `rake integration`: This will run all of the kitchen tests

### Test Cookbook (netapp_docker_test):
_a test cookbook for the available LWRPs_

For the purposes of testing and validating this code, we have included a test cookbook with pre-configured recipes.  The LWRP unit tests leverage these recipes to verify configuration.

#### Recipes

| **Name** | **Description** |
| ------------- |-------------|
| _Default_ | Roll-up recipe to test all of the functionality of the LWRP-specific recipes |
| _ontap_nas_ | Test the **ontap_plugin** provider for ontap-nas configurations. |
| _ontap_san_ | Test the **ontap_plugin** provider for ontap-san configurations. |

#### Recipe attributes: ontap_nas

| Attribute | Type | Description | Default |
| ------------- |-------------|-------------|-------------|
| **`node['netapp_docker_test']['config']['netapp']['ontap_mgmt_ip']`** | String | IP or Hostname for the NetApp Storage Virtual Machine Manaegment (SVM) LIF | nil |
| **`node['netapp_docker_test']['config']['netapp']['ontap_data_ip']`** | String | IP or Hostname for the NetApp Storage Virtual Machine NFS or iSCSI LIF | nil |
| **`node['netapp_docker_test']['config']['netapp']['svm']`** | String | NetApp Storage Virtual Machine name | nil |
| **`node['netapp_docker_test']['config']['netapp']['username']`** | String | Assigned NetApp Aggregate to use for provisioning. Requires that the aggregate be listed in the SVM aggr_list | nil |
| **`node['netapp_docker_test']['config']['netapp']['password']`** | String | Storage Virtual Machine username | nil |
| **`node['netapp_docker_test']['config']['netapp']['aggregate']`** | String | Storage Virtual Machine user password | nil |
| **`node['netapp_docker_test']['config']['netapp']['prefix']`** | String | Sets the NetApp volume name prefix.  Defaults to the plug-in name | nil |

#### Recipe attributes: ontap_san

| Attribute | Type | Description | Default |
| ------------- |-------------|-------------|-------------|
| **`node['netapp_docker_test']['config']['ontap_iscsi']['ontap_mgmt_ip']`** | String | IP or Hostname for the NetApp Storage Virtual Machine Manaegment (SVM) LIF | nil |
| **`node['netapp_docker_test']['config']['ontap_iscsi']['ontap_data_ip']`** | String | IP or Hostname for the NetApp Storage Virtual Machine NFS or iSCSI LIF | nil |
| **`node['netapp_docker_test']['config']['ontap_iscsi']['svm']`** | String | NetApp Storage Virtual Machine name | nil |
| **`node['netapp_docker_test']['config']['ontap_iscsi']['username']`** | String | Assigned NetApp Aggregate to use for provisioning. Requires that the aggregate be listed in the SVM aggr_list | nil |
| **`node['netapp_docker_test']['config']['ontap_iscsi']['password']`** | String | Storage Virtual Machine username | nil |
| **`node['netapp_docker_test']['config']['ontap_iscsi']['aggregate']`** | String | Storage Virtual Machine user password | nil |
| **`node['netapp_docker_test']['config']['ontap_iscsi']['prefix']`** | String | Sets the NetApp volume name prefix.  Defaults to the plug-in name | nil |

#### Compliance Profile for Test Cookbook
Included in this cookbook is a set of Inspec profile tests used for supported platforms in Test-Kitchen when run against the Test Cookbook. The Control files are located at `test/smoke/suite_name`


## License & Authors

**Author:** Jeremy Goodrum ([jeremy@exospheredata.com](mailto:jeremy@exospheredata.com))

**Copyright:** 2017 Exosphere Data, LLC

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
