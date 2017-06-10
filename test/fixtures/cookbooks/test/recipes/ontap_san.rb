#
# Cookbook:: netapp_docker_test
# Recipe:: ontap_nas
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

netapp_docker_ontap_plugin 'ontap_iscsi' do
  ndvp_config 'ontap_iscsi'
  config_type 'ontap-san'
  ontap_mgmt_ip node['netapp_docker_test']['config']['ontap_iscsi']['ontap_mgmt_ip']
  ontap_data_ip node['netapp_docker_test']['config']['ontap_iscsi']['ontap_data_ip']
  svm node['netapp_docker_test']['config']['ontap_iscsi']['svm']
  username node['netapp_docker_test']['config']['ontap_iscsi']['username']
  password node['netapp_docker_test']['config']['ontap_iscsi']['password']
  aggregate node['netapp_docker_test']['config']['ontap_iscsi']['aggregate']
  action [:config, :install]
end

execute 'Create test san volume' do
  command <<-EOF
  docker volume create -d ontap_iscsi lunsan --opt 5g
  EOF
  action :run
end
