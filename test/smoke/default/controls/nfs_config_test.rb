#
# Profile:: netapp-docker-volume-plugin-test
# Control:: nfs_config_test
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

title 'NetApp Docker Volume Plugin: NFS configuration'

control 'ndvp-nfs-config-test-1.0' do
  impact 1.0
  title 'Validate NFS installed'
  desc 'Verify required NFS tools and client is installed'

  describe.one do
    describe package('nfs-common') do
      it { should be_installed }
    end
    describe package('nfs-utils') do
      it { should be_installed }
    end
  end
end

control 'ndvp-nfs-config-test-1.1' do
  impact 1.0
  title 'Validate rpcbind service'
  desc 'Verify required rpcbind services is up and running'

  describe service('rpcbind') do
    it { should be_enabled }
    it { should be_running }
  end
end

control 'ndvp-nfs-config-test-1.2' do
  impact 1.0
  title 'Validate rpcbind service'
  desc 'Verify that the iscsi directory exists due to NDVP issue - https://github.com/NetApp/netappdvp/issues/82'

  describe file('/etc/iscsi') do
    it { should be_directory }
  end
end
