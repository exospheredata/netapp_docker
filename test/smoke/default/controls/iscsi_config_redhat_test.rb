#
# Profile:: netapp-docker-volume-plugin-test
# Control:: nfs_config_test
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

title 'NetApp Docker Volume Plugin: ISCSI configuration for Redhat/Centos/AWS'

control 'ndvp-iscsi-redhat-config-test-1.0' do
  impact 1.0
  title 'Validate ISCSI installed'
  desc 'Verify required ISCSI tools and services are installed'

  only_if { os[:family] == 'redhat' }

  %w(lsscsi iscsi-initiator-utils sg3_utils device-mapper-multipath).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
end

control 'ndvp-iscsi-redhat-config-test-1.1' do
  impact 1.0
  title 'Validate iSCSI services'
  desc 'Verify required ISCSI services are up and running'

  only_if { os[:family] == 'redhat' }

  # Need to add iscsi once we have the iSCSI login ready.
  %w(iscsid multipathd).each do |srv|
    describe service(srv) do
      it { should be_enabled }
      it { should be_running }
    end
  end
end

control 'ndvp-iscsi-redhat-config-test-1.2' do
  impact 1.0
  title 'Validate multipath configuration file'
  desc 'Verify that the multipath configuration exists'

  only_if { os[:family] == 'redhat' }

  describe file('/etc/multipath.conf') do
    it { should be_file }
    it { should_not be_executable }
    it { should be_readable }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0600' }
  end
end
