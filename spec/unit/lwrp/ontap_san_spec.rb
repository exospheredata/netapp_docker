#
# Cookbook:: docker_mysql_load_gen
# Spec:: ontap_san
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

require 'spec_helper'

describe 'netapp_docker_test::ontap_san' do
  before do
    stub_command('docker plugin list | grep ontap_iscsi:latest').and_return(false)
    stub_command('docker plugin list | grep ontap_iscsi | grep false').and_return(true)
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
            node.normal['netapp_docker_test']['config']['ontap_iscsi']['ontap_mgmt_ip'] = '192.168.100.184'
            node.normal['netapp_docker_test']['config']['ontap_iscsi']['ontap_data_ip'] = '192.168.100.186'
            node.normal['netapp_docker_test']['config']['ontap_iscsi']['svm'] = 'svm_applicationcloud'
            node.normal['netapp_docker_test']['config']['ontap_iscsi']['aggregate'] = 'aggr1'
            node.normal['netapp_docker_test']['config']['ontap_iscsi']['username'] = 'kitchen'
            node.normal['netapp_docker_test']['config']['ontap_iscsi']['password'] = 'netapp123'
          end
          let(:runner) do
            ChefSpec::SoloRunner.new(platform: platform, version: version, step_into: ['netapp_docker_ontap_plugin'])
          end
          let(:node) { runner.node }
          let(:chef_run) { runner.converge(described_recipe) }

          it 'converges successfully' do
            expect { chef_run }.to_not raise_error
            expect(chef_run).to config_netapp_docker_ontap_plugin('ontap_iscsi')
            expect(chef_run).to install_netapp_docker_ontap_plugin('ontap_iscsi')
            expect(chef_run).to run_execute('Create test san volume')

            # LWRP Actions
            expect(chef_run).to create_docker_installation('default')
            expect(chef_run).to enable_service('docker')
            expect(chef_run).to start_service('docker')
            expect(chef_run).to create_directory('Directory path for ontap_iscsi.json')
            expect(chef_run).to create_file('/etc/netappdvp/ontap_iscsi.json')
            expect(chef_run).to run_execute('Install NetApp Docker Volume Plugin')
            expect(chef_run).to run_execute('Enable NetApp Docker Volume Plugin')
            case platform
            when 'redhat', 'centos'
              %w(lsscsi iscsi-initiator-utils sg3_utils device-mapper-multipath).each do |pkg|
                expect(chef_run).to install_package(pkg)
              end
              expect(chef_run).to run_execute('Setup Multipath daemon')
              %w(iscsid multipathd iscsi).each do |srv|
                expect(chef_run).to enable_service(srv)
                expect(chef_run).to start_service(srv)
              end

            when 'ubuntu', 'debian'
              %w(open-iscsi lsscsi sg3-utils multipath-tools scsitools).each do |pkg|
                expect(chef_run).to install_package(pkg)
              end
              expect(chef_run).to create_file('/etc/multipath.conf')
              %w(open-iscsi multipath-tools).each do |srv|
                expect(chef_run).to enable_service(srv)
                expect(chef_run).to start_service(srv)
              end

            end
            expect(chef_run).to run_execute('Discover iSCSI Target')
            expect(chef_run).to run_execute('Log into iSCSI Target')
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