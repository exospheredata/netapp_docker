#
# Cookbook:: netapp_docker
# CustomResource:: ontap_plugin
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default_action :config

# NetApp Docker Volume Plugin
property :config_name, String, name_property: true, required: true # Sets the plugin name in the style of <config>:<version. Default: 'netapp'
property :ndvp_config, String, default: 'config.json'
property :config_type, String, equal_to: %w(ontap-nas ontap-san), default: 'ontap-nas'
property :plugin_version, String, default: 'latest'

# ONTAP details
property :ontap_mgmt_ip, String, required: true, regex: [/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/]
property :ontap_data_ip, String, required: true, regex: [/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/]
property :svm, String, required: true
property :username, String, required: true, sensitive: true
property :password, String, required: true, sensitive: true
property :aggregate, String, required: true
property :prefix, [String, nil] # The default is 'netappdvp_'
property :nfs_mount_options, [String, nil] # This option should be passed in valid NFS mount option format such as '-o nfsvers=3'

# Optional values
property :default_size, [String, nil] # Should be in the format of Size and then single character classifier.  Example '20g'
property :default_space_reserve, [String, nil], kind_of: %w(none thick) # Sets the volume efficiency policy regarding space consumption.  Default is 'none'
property :default_snapshot_policy, [String, nil] # Must be a valid and existing snapshot policy name.  Defaul is 'none'
property :default_split_on_clone, [TrueClass, FalseClass] # Determines if the volume clone should be split on creation.  Default is false.
property :default_security_style, [String, nil], kind_of: %w(unix mixed) # Default value is unix

## only valid for NAS configurations
property :default_export, [String, nil] # Sets the default export policy to assign to newly created volumes.  Must exist.  Default is 'default'
property :default_unix_permissions, [String, nil] # Valid unix permission mode for newly created volumes.  Default is '0777'
property :default_snapshot_dir, [TrueClass, FalseClass] # Determines if the .snapshot directory should be visibile within the mount.  Default is false

action :install do
  # Install the correct NAS or SAN packages depending on the OS
  install_docker

  case new_resource.config_type
  when 'ontap-nas'
    install_nas
  when 'ontap-san'
    install_san
  else
    raise 'Failed to install nDVP due to illegal content-type'
  end

  converge_by("#{new_resource.name}: Install NetApp Docker Volume configuration") do
    # TODO: Add checks to ensure Docker version at supported levels as well
    execute "#{new_resource.name}: Install NetApp Docker Volume Plug-in" do
      command <<-EOF
      docker plugin install --grant-all-permissions netapp/ndvp-plugin:#{new_resource.plugin_version} \
      --alias #{new_resource.config_name} config=/etc/netappdvp/#{new_resource.ndvp_config}
      EOF
      not_if "docker plugin list | grep #{new_resource.config_name}:#{new_resource.plugin_version}"
    end

    execute "#{new_resource.name}: Enable NetApp Docker Volume Plug-in" do
      command "docker plugin enable #{new_resource.config_name}"
      only_if "docker plugin list | grep #{new_resource.config_name} | grep false"
    end
  end

  return new_resource.updated_by_last_action(true)
end

action :config do
  # The configuration file must end in a .json format so we will
  # add the extension if it does not exist.
  unless new_resource.ndvp_config.include? '.json'
    new_resource.ndvp_config += '.json'
  end

  # Create the directory for the configuration files. Due to CHEF-3694, we need
  # to have unique names for the directory resource otherwise, it will report
  # that we are using resource cloning when multiple resources are declared.
  directory "#{new_resource.name}: Directory /etc/netappdvp" do
    path '/etc/netappdvp'
    recursive true
    action :create
  end

  # Create the required configuration files based on the supplied parameters
  # Using a hash since there are many optional parameters and then creating
  # the file.
  config_file = {}
  config_file['version'] = 1
  config_file['storageDriverName'] = new_resource.config_type
  config_file['managementLIF']     = new_resource.ontap_mgmt_ip
  config_file['dataLIF']           = new_resource.ontap_data_ip
  config_file['svm']               = new_resource.svm
  config_file['username']          = new_resource.username
  config_file['password']          = new_resource.password
  config_file['aggregate']         = new_resource.aggregate
  config_file['storagePrefix']     = new_resource.prefix if new_resource.prefix
  config_file['nfsMountOptions']   = new_resource.nfs_mount_options if new_resource.nfs_mount_options

  defaults = {}
  defaults['size']            = new_resource.default_size if new_resource.default_size
  defaults['exportPolicy']    = new_resource.default_export if new_resource.default_export
  defaults['spaceReserve']    = new_resource.default_space_reserve if new_resource.default_space_reserve
  defaults['snapshotPolicy']  = new_resource.default_snapshot_policy if new_resource.default_snapshot_policy
  defaults['splitOnClone']    = new_resource.default_split_on_clone if new_resource.default_split_on_clone
  defaults['unixPermissions'] = new_resource.default_unix_permissions if new_resource.default_unix_permissions
  defaults['snapshotDir']     = new_resource.default_snapshot_dir if new_resource.default_snapshot_dir
  defaults['securityStyle']   = new_resource.default_security_style if new_resource.default_security_style

  config_file['defaults'] = defaults unless defaults.empty?

  file "#{new_resource.name}: /etc/netappdvp/#{new_resource.ndvp_config}" do
    path "/etc/netappdvp/#{new_resource.ndvp_config}"
    content JSON.pretty_generate(config_file)
    mode '0755'
    sensitive false
    action :create
  end

  return new_resource.updated_by_last_action(true)
end

action :enable do
  execute "#{new_resource.name}: Enable NetApp Docker Volume Plug-in" do
    command "docker plugin enable #{new_resource.config_name}"
    only_if "docker plugin list | grep #{new_resource.config_name} | grep true"
  end
  return new_resource.updated_by_last_action(true)
end

action :disable do
  execute "#{new_resource.name}: Disable NetApp Docker Volume Plug-in" do
    command "docker plugin disable #{new_resource.config_name}"
    only_if "docker plugin list | grep #{new_resource.config_name} | grep true"
  end
  return new_resource.updated_by_last_action(true)
end

action :delete do
  # Future Property that does nothing as of now
  return new_resource.updated_by_last_action(false)
end

action_class do
  def whyrun_supported?
    true
  end

  def install_docker
    converge_by("Install Docker services: #{new_resource.ndvp_config}") do
      docker_installation "#{new_resource.name}: default" do
        action :create
      end

      # By default, other users will need to be added to the Docker unix group in order to have non-sudo
      # required access to the docker binary.  This array will add the users.
      group "#{new_resource.name}: docker" do
        group_name 'docker'
        members node['docker']['members']
        append true
        not_if { node['docker']['members'].nil? }
      end

      service "#{new_resource.name}: docker" do
        service_name 'docker'
        action [:enable, :start]
      end
    end
  end

  def install_nas
    converge_by('Install NAS prerequisites for nDVP') do
      case node['platform']
      when 'debian', 'ubuntu'
        package "#{new_resource.name}: nfs-common" do
          package_name 'nfs-common'
          action :install
        end
      when 'centos', 'redhat', 'amazon'
        package "#{new_resource.name}: nfs-utils" do
          package_name 'nfs-utils'
          action :install
        end
      else
        raise 'Unsupported platform.  Unable to install the NetApp docker prerequisites for NAS'
      end

      service "#{new_resource.name}: rpcbind" do
        service_name 'rpcbind'
        action [:enable, :start]
      end

      directory "#{new_resource.name}: /etc/iscsi" do
        # https://github.com/NetApp/netappdvp/issues/82
        path '/etc/iscsi'
        action :create
      end

      directory "#{new_resource.name}: /etc/systemd/system/docker.service.d/" do
        path '/etc/systemd/system/docker.service.d/'
        recursive true
        action :create
      end

      file "#{new_resource.name}: /etc/systemd/system/docker.service.d/netappdvp.conf" do
        path '/etc/systemd/system/docker.service.d/netappdvp.conf'
        content <<-EOF
      [Unit]
      Requires=rpcbind.service
      EOF
        mode '0755'
        action :create
        notifies :run, "execute[#{new_resource.name}: systemctl daemon-reload]", :immediately
      end

      execute "#{new_resource.name}: systemctl daemon-reload" do
        command 'systemctl daemon-reload'
        action :nothing
      end
    end
  end

  def install_san
    converge_by('Install SAN prerequisites for nDVP') do
      case node['platform']
      when 'debian', 'ubuntu'
        install_debian_san
      when 'centos', 'redhat', 'amazon'
        install_redhat_san
      else
        raise 'Unsupported platform.  Unable to install the NetApp docker prerequisites for SAN'
      end

      discover_iscsi_targets
    end
  end

  def install_debian_san
    %w(open-iscsi lsscsi sg3-utils multipath-tools scsitools).each do |pkg|
      package "#{new_resource.name}: #{pkg}" do
        package_name pkg
        action :install
      end
    end

    file "#{new_resource.name}: /etc/multipath.conf" do
      path '/etc/multipath.conf'
      content <<-EOF
    defaults {
        user_friendly_names yes
        find_multipaths yes
    }
    EOF
      mode '0644'
      action :create
    end

    %w(open-iscsi multipath-tools).each do |srv|
      service "#{new_resource.name}: #{srv}" do
        service_name srv
        action [:enable, :start]
      end
    end
  end

  def install_redhat_san
    %w(lsscsi iscsi-initiator-utils sg3_utils device-mapper-multipath).each do |pkg|
      package "#{new_resource.name}: #{pkg}" do
        package_name pkg
        action :install
      end
    end

    execute "#{new_resource.name}: Setup Multipath daemon" do
      command 'mpathconf --enable --with_multipathd y'
    end

    %w(iscsid multipathd iscsi).each do |srv|
      service "#{new_resource.name}: #{srv}" do
        service_name srv
        action [:enable, :start]
      end
    end
  end

  def discover_iscsi_targets
    execute "#{new_resource.name}: Discover iSCSI Target" do
      command "iscsiadm -m discoverydb -t st -p #{new_resource.ontap_data_ip} --discover"
    end

    execute "#{new_resource.name}: Log into iSCSI Target" do
      command "iscsiadm -m node -p #{new_resource.ontap_data_ip} --login"
      not_if "iscsiadm -m session | grep #{new_resource.ontap_data_ip}"
    end
  end
end
