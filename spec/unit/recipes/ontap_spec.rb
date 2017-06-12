#
# Cookbook:: netapp_docker
# Spec:: ontap_spec
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

require 'spec_helper'

describe 'netapp_docker::ontap' do
  before do
    stub_command('docker plugin list | grep netapp:latest').and_return(false)
    stub_command('docker plugin list | grep netapp | grep false').and_return(true)
  end
  context 'Install prequisite components' do
    platforms = {
      'ubuntu' => {
        'versions' => %w(14.04 16.04)
      },
      'debian' => {
        'versions' => %w(7.8)
      },
      'centos' => {
        'versions' => %w(7.1.1503 7.2.1511)
      },
      'redhat' => {
        'versions' => %w(7.1 7.2)
      }
    }

    platforms.each do |platform, components|
      components['versions'].each do |version|
        context "On #{platform} #{version}" do
          before do
            Fauxhai.mock(platform: platform, version: version)
            node.normal['netapp_docker']['config']['ndvp_config'] = 'netapp'
            node.normal['netapp_docker']['config']['ontap_mgmt_ip'] = '192.168.100.184'
            node.normal['netapp_docker']['config']['ontap_data_ip'] = '192.168.100.186'
            node.normal['netapp_docker']['config']['svm'] = 'svm_applicationcloud'
            node.normal['netapp_docker']['config']['aggregate'] = 'aggr1'
            node.normal['netapp_docker']['config']['username'] = 'kitchen'
            node.normal['netapp_docker']['config']['password'] = 'netapp123'
          end
          let(:runner) do
            ChefSpec::SoloRunner.new(platform: platform, version: version)
          end
          let(:node) { runner.node }
          let(:chef_run) { runner.converge(described_recipe) }

          it 'converges successfully' do
            expect { chef_run }.to_not raise_error
            expect(chef_run).to config_netapp_docker_ontap_plugin('netapp')
            expect(chef_run).to install_netapp_docker_ontap_plugin('netapp')
          end
        end
      end
    end
  end
end
