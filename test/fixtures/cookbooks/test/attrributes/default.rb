#
# Cookbook:: netapp_docker_test
# Attribute:: default
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

%w(netapp ontap_iscsi).each do |config|
  default['netapp_docker_test']['config'][config]['ontap_mgmt_ip'] = nil
  default['netapp_docker_test']['config'][config]['ontap_data_ip'] = nil
  default['netapp_docker_test']['config'][config]['svm'] = nil
  default['netapp_docker_test']['config'][config]['aggregate'] = nil
  default['netapp_docker_test']['config'][config]['username'] = nil
  default['netapp_docker_test']['config'][config]['password'] = nil
end
