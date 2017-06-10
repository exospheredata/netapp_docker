#
# Cookbook:: docker_mysql_load_gen
# Spec:: ontap_nas
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

require 'spec_helper'

describe 'netapp_docker_test::ontap_nas' do
  before do
    stub_command('docker plugin list | grep netapp:latest').and_return(false)
    stub_command('docker plugin list | grep netapp | grep false').and_return(true)
  end
  context 'Succesfully converge' do
    platforms = {
      'ubuntu' => {
        'versions' => ['12.04', '14.04', '16.04']
      },
      'debian' => {
        'versions' => ['7.8']
      },
      'centos' => {
        'versions' => ['6.8', '7.0']
      },
      'redhat' => {
        'versions' => ['6.5', '7.2']
      }
    }

    platforms.each do |platform, components|
      components['versions'].each do |version|
        context "On #{platform} #{version}" do
          before do
            Fauxhai.mock(platform: platform, version: version)
            node.normal['netapp_docker_test']['config']['netapp']['ontap_mgmt_ip'] = '192.168.100.184'
            node.normal['netapp_docker_test']['config']['netapp']['ontap_data_ip'] = '192.168.100.186'
            node.normal['netapp_docker_test']['config']['netapp']['svm'] = 'svm_applicationcloud'
            node.normal['netapp_docker_test']['config']['netapp']['aggregate'] = 'aggr1'
            node.normal['netapp_docker_test']['config']['netapp']['username'] = 'kitchen'
            node.normal['netapp_docker_test']['config']['netapp']['password'] = 'netapp123'
          end
          let(:runner) do
            ChefSpec::SoloRunner.new(platform: platform, version: version, step_into: ['netapp_docker_ontap_plugin'])
          end
          let(:node) { runner.node }
          let(:chef_run) { runner.converge(described_recipe) }

          it 'converges successfully' do
            expect { chef_run }.to_not raise_error
            expect(chef_run).to config_netapp_docker_ontap_plugin('netapp')
            expect(chef_run).to install_netapp_docker_ontap_plugin('netapp')
            expect(chef_run).to run_execute('Create test nas volume')

            # LWRP Actions
            expect(chef_run).to create_docker_installation('default')
            expect(chef_run).to enable_service('docker')
            expect(chef_run).to start_service('docker')
            expect(chef_run).to create_directory('Directory path for config.json')
            expect(chef_run).to create_file('/etc/netappdvp/config.json')
            case platform
            when 'redhat', 'centos'
              expect(chef_run).to install_package('nfs-utils')
            when 'ubuntu', 'debian'
              expect(chef_run).to install_package('nfs-common')
            end
            expect(chef_run).to enable_service('rpcbind')
            expect(chef_run).to start_service('rpcbind')
            expect(chef_run).to create_directory('/etc/iscsi')
            expect(chef_run).to create_directory('/etc/systemd/system/docker.service.d/')
            expect(chef_run).to create_file('/etc/systemd/system/docker.service.d/netappdvp.conf')
            systemctl = chef_run.execute('systemctl daemon-reload')
            expect(systemctl).to do_nothing
            conf_file = chef_run.file('/etc/systemd/system/docker.service.d/netappdvp.conf')
            expect(conf_file).to notify('execute[systemctl daemon-reload]').to(:run).immediately
            expect(chef_run).to run_execute('Install NetApp Docker Volume Plugin')
            expect(chef_run).to run_execute('Enable NetApp Docker Volume Plugin')
          end
          it 'grants users access to docker group' do
            node.normal['docker']['members'] = 'root'
            expect(chef_run).to create_group('docker')
          end
        end
      end
    end
  end
end
