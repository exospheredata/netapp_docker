#
# Cookbook:: netapp_docker_test
# Recipe:: ontap_nas
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

netapp_docker_ontap_plugin 'netapp' do
  ontap_mgmt_ip node['netapp_docker_test']['config']['netapp']['ontap_mgmt_ip']
  ontap_data_ip node['netapp_docker_test']['config']['netapp']['ontap_data_ip']
  svm node['netapp_docker_test']['config']['netapp']['svm']
  username node['netapp_docker_test']['config']['netapp']['username']
  password node['netapp_docker_test']['config']['netapp']['password']
  aggregate node['netapp_docker_test']['config']['netapp']['aggregate']
  prefix node['netapp_docker_test']['config']['netapp']['prefix']
  nfs_mount_options '-o nfsvers=3'
  default_size '5g'
  default_export 'default'
  action [:config, :install]
end

execute 'Create test nas volume' do
  command <<-EOF
  docker volume create -d netapp nas_01 --opt 8g
  EOF
  action :run
end
