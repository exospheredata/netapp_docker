# Helper:: WindowsHelper
#
# Author:: Exosphere Data, LLC
# Email:: chef@exospheredata.com
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.
#
# ChefSpec Windows Helper methods

def mock_windows_system_framework
  allow_any_instance_of(Chef::Recipe)
    .to receive(:wmi_property_from_query)
    .and_return(true)
  allow_any_instance_of(Chef::DSL::RegistryHelper)
    .to receive(:registry_key_exists?)
    .and_return(false)
  allow_any_instance_of(Chef::DSL::RegistryHelper)
    .to receive(:registry_get_values)
    .and_return(nil)
  allow_any_instance_of(Chef::Win32::Registry)
    .to receive(:value_exists?)
    .and_return(false)
  # This is the best way that I could find to stub out the Windows::Helper
  # 'is_package_installed?'.
  allow_any_instance_of(Chef::Provider)
    .to receive(:is_package_installed?)
    .and_return(false)
end

def win_friendly_path(path)
  path.gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR || '\\') if path
end
