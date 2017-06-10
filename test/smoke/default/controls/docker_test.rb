#
# Profile:: netapp-docker-volume-plugin-test
# Control:: docker_test
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

title 'NetApp Docker Volume Plugin: docker configuration'

control 'ndvp-docker-test-1.0' do
  impact 1.0
  title 'Validate docker'
  desc 'Verify required docker components exist'

  describe service('docker') do
    it { should be_enabled }
    it { should be_running }
  end

  describe etc_group.where(group_name: 'docker') do
    its('users') { should include 'vagrant' }
  end
end
