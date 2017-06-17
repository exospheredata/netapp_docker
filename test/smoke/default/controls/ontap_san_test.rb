#
# Profile:: netapp-docker-volume-plugin-test
# Control:: ontap_san_test
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

title 'NetApp Docker Volume Plugin: ontap-san driver'

control 'ontap-san-test-1.0' do
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

control 'ontap-san-test-1.1' do
  impact 1.0
  title 'Validate default nDVP configuration'
  desc 'Verify default configuration file exists'

  describe file('/etc/netappdvp/ontap_iscsi.json') do
    it { should be_file }
    it { should be_executable }
    it { should be_readable }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0755' }
  end

  describe ndvp_config('/etc/netappdvp/ontap_iscsi.json') do
    its('version') { should eq(1) }
    its('storageDriverName') { should eq('ontap-san') }
    its('defaults') { should be_empty }
  end
end
