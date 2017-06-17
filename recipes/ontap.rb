#
# Cookbook:: netapp_docker
# Recipe:: ontap
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

netapp_docker_ontap_plugin node['netapp_docker']['config']['ndvp_config'] do
  ndvp_config node['netapp_docker']['config']['ndvp_config']
  config_type node['netapp_docker']['config']['config_type']
  plugin_version node['netapp_docker']['config']['plugin_version']
  ontap_mgmt_ip  node['netapp_docker']['config']['ontap_mgmt_ip']
  ontap_data_ip  node['netapp_docker']['config']['ontap_data_ip']
  svm node['netapp_docker']['config']['svm']
  username   node['netapp_docker']['config']['username']
  password   node['netapp_docker']['config']['password']
  aggregate  node['netapp_docker']['config']['aggregate']
  prefix node['netapp_docker']['config']['prefix'] # Optional.  Default is 'netappdvp_'
  nfs_mount_options node['netapp_docker']['config']['nfs_mount_options'] # Optional
  default_size   node['netapp_docker']['config']['defaults']['size'] # Optional
  default_space_reserve node['netapp_docker']['config']['defaults']['space_reserve'] # Optional. Default is '20g'
  default_snapshot_policy  node['netapp_docker']['config']['defaults']['snapshot_policy'] # Optional. Default is 'none'
  default_split_on_clone   node['netapp_docker']['config']['defaults']['split_on_clone'] # Optional. Default is 'false'
  default_security_style   node['netapp_docker']['config']['defaults']['security_style'] # Optional. Default is 'unix'
  default_export node['netapp_docker']['config']['defaults']['export'] # Optional. Default is 'default'
  default_unix_permissions node['netapp_docker']['config']['defaults']['unix_permissions'] # Optional. Default is '0777'
  default_snapshot_dir node['netapp_docker']['config']['defaults']['snapshot_dir'] # Optional. Default is 'false'
  action [:config, :install]
end
