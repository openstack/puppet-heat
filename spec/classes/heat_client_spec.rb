require 'spec_helper'

describe 'heat::client' do

  let :params do
    {}
  end

  let :default_params do
    { :package_ensure   => 'present' }
  end

  shared_examples_for 'heat client' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('heat::params') }

    it 'installs heat client package' do
      is_expected.to contain_package('python-heatclient').with(
        :name   => 'python-heatclient',
        :ensure => p[:package_ensure],
        :tag    => 'openstack'
      )
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'heat client'
    end
  end

end
