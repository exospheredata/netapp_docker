#
# Cookbook:: netapp_docker
# Spec:: default_spec
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2017, Exosphere Data, LLC, All Rights Reserved.

require 'spec_helper'

describe 'netapp_docker::default' do
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
          end

          let(:chef_run) { ChefSpec::SoloRunner.new(platform: platform, version: version).converge(described_recipe) }

          it 'converges successfully' do
            expect { chef_run }.to_not raise_error
          end
        end
      end
    end
  end
end
