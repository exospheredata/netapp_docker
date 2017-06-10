# test
### _Installs/Configures test_

TODO: Enter the cookbook description here.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [test](#test)
  - [Requirements](#requirements)
    - [Platforms](#platforms)
    - [Chef](#chef)
    - [Cookbooks](#cookbooks)
    - [Data bag](#data-bag)
  - [Attributes](#attributes)
  - [Usage](#usage)
    - [default](#default)
  - [Upload to Chef Server](#upload-to-chef-server)
  - [Matchers/Helpers](#matchershelpers)
    - [Matchers](#matchers)
    - [Helpers](#helpers)
  - [Cookbook Testing](#cookbook-testing)
    - [Before you begin](#before-you-begin)
    - [Data_bags for Test-Kitchen](#data_bags-for-test-kitchen)
    - [Rakefile and Tasks](#rakefile-and-tasks)
    - [Chefspec and Test-Kitchen](#chefspec-and-test-kitchen)
    - [Compliance Profile](#compliance-profile)
  - [Copyright:: 2017, Exosphere Data LLC, All Rights Reserved.](#copyright-2017-exosphere-data-llc-all-rights-reserved)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Requirements

### Platforms

TODO: List all supported Platforms and versions. 

### Chef

- 12.5+

TODO: Minimum supported version of CHEF client supported by this cookbook

### Cookbooks

TODO: Identify any cookbook dependencies

### Data bag

TODO: List all supported data_bag names, model, and items.

## Attributes

TODO: Enter all available node attributes including description, field type, and default value.


## Usage
### default

This is an empty recipe and should _not_ be used

TODO: Write descriptions about any included recipes

## Upload to Chef Server
This cookbook should be included in each organization of your CHEF environment.  When importing, leverage Berkshelf:

`berks upload`

_NOTE:_ use the --no-ssl-verify switch if the CHEF server in question has a self-signed SSL certificate.

`berks upload --no-ssl-verify`

## Matchers/Helpers

### Matchers
_Note: Matchers should always be created in `libraries/matchers.rb` and used for validating calls to LWRP_

TODO: Add details about any matcher files included in this cookbook


### Helpers

TODO: Add details about any helper files included in this cookbook

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
│   │   ├── test
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
| **rake maintainers:generate** | Generate MarkDown version of MAINTAINERS file |

### Chefspec and Test-Kitchen

1. `bundle install`: Installs and pulls all ruby gems dependencies from the Gemfile.

2. `berks install`: Installs all cookbook dependencies based on the [Berksfile](Berksfile) and the [metadata.rb](metadata.rb)

3. `rake`: This will run all of the local tests - syntax, lint, unit, and maintainers file.
4. `rake integration`: This will run all of the kitchen tests 

### Compliance Profile
Included in this cookbook is a set of Inspec profile tests used for supported platforms in Test-Kitchen.  These profiles can also be loaded into Chef Compliance to ensure on-going validation.  The Control files are located at `test/smoke/suite_name`


## Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.
