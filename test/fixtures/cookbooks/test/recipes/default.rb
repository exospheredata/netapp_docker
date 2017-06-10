#
# Cookbook:: netapp_docker_test
# Recipe:: default
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

include_recipe 'netapp_docker_test::ontap_nas'
include_recipe 'netapp_docker_test::ontap_san'
