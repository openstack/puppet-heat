require 'spec_helper'

describe 'heat::client' do

  shared_examples_for 'heat client' do

    it { is_expected.to contain_class('heat::deps') }
    it { is_expected.to contain_class('heat::params') }

    it 'installs heat client package' do
      is_expected.to contain_package('python-heatclient').with(
        :name   => platform_params[:client_package_name],
        :ensure => 'present',
        :tag    => ['openstack', 'openstackclient', 'heat-package']
      )
    end

    it { is_expected.to contain_class('openstacklib::openstackclient') }
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          { :client_package_name => 'python3-heatclient' }
        when 'RedHat'
          { :client_package_name => 'python3-heatclient' }
        end
      end

      it_behaves_like 'heat client'
    end
  end

end
