#
# Profile:: netapp-docker-volume-plugin-test
# Control:: ontap_nas_test
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

title 'NetApp Docker Volume Plugin: ontap-nas driver'

control 'ontap-nas-test-1.0' do
  impact 1.0
  title 'Validate /etc/netappdvp directory'
  desc 'Verify required configuration directory exists'

  describe file('/etc/netappdvp') do
    it { should be_directory }
    it { should be_executable }
    it { should be_readable }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0755' }
  end
end

control 'ontap-nas-test-1.1' do
  impact 1.0
  title 'Validate default nDVP configuration'
  desc 'Verify default configuration file exists'

  describe file('/etc/netappdvp/config.json') do
    it { should be_file }
    it { should be_executable }
    it { should be_readable }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0755' }
  end

  describe ndvp_config('/etc/netappdvp/config.json') do
    its('version') { should eq(1) }
    its('storageDriverName') { should eq('ontap-nas') }
    its('defaults') { should_not be_empty }
  end

  describe ndvp_config_defaults('/etc/netappdvp/config.json') do
    its('size') { should eq('5g') }
    its('exportPolicy') { should eq('default') }
  end
end
