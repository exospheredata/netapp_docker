#
# Cookbook:: netapp_docker
# Attribute:: default
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

default['docker']['members'] = nil

# Required parameters
default['netapp_docker']['config']['ndvp_config'] = 'netapp'
default['netapp_docker']['config']['config_type'] = 'ontap-nas'
default['netapp_docker']['config']['ontap_mgmt_ip'] = nil
default['netapp_docker']['config']['ontap_data_ip'] = nil
default['netapp_docker']['config']['svm'] = nil
default['netapp_docker']['config']['aggregate'] = nil
default['netapp_docker']['config']['username'] = nil
default['netapp_docker']['config']['password'] = nil

# Optional parameters
default['netapp_docker']['config']['prefix'] = nil
default['netapp_docker']['config']['nfs_mount_options'] = nil

default['netapp_docker']['config']['defaults']['size'] = nil
default['netapp_docker']['config']['defaults']['space_reserve'] = nil
default['netapp_docker']['config']['defaults']['snapshot_policy'] = nil
default['netapp_docker']['config']['defaults']['split_on_clone'] = nil
default['netapp_docker']['config']['defaults']['security_style'] = nil

## only valid for NAS configurations
default['netapp_docker']['config']['defaults']['export'] = nil
default['netapp_docker']['config']['defaults']['unix_permissions'] = nil
default['netapp_docker']['config']['defaults']['snapshot_dir'] = nil
