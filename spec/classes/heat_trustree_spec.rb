require 'spec_helper'

describe 'heat::trustee' do

  shared_examples_for 'heat::trustee' do

    context 'with defaults' do
      let :params do
        {}
      end
      it 'configures trustee options' do
        is_expected.to contain_heat_config('trustee/password').with_value('<SERVICE DEFAULT>').with_secret(true)
        is_expected.to contain_heat_config('trustee/auth_url').with_value('http://127.0.0.1:5000/')
        is_expected.to contain_heat_config('trustee/auth_type').with_value('password')
        is_expected.to contain_heat_config('trustee/username').with_value('heat')
        is_expected.to contain_heat_config('trustee/user_domain_name').with_value('Default')
      end
    end

    context 'with parameters overridden' do
      let :params do
        {
          :password         => 'heat_password',
          :auth_type        => 'v3password',
          :auth_url         => 'https://localhost:13000/',
          :username         => 'alt_heat',
          :user_domain_name => 'MyDomain',
        }
      end
      it 'configures trustee options' do
        is_expected.to contain_heat_config('trustee/password').with_value('heat_password').with_secret(true)
        is_expected.to contain_heat_config('trustee/auth_url').with_value('https://localhost:13000/')
        is_expected.to contain_heat_config('trustee/auth_type').with_value('v3password')
        is_expected.to contain_heat_config('trustee/username').with_value('alt_heat')
        is_expected.to contain_heat_config('trustee/user_domain_name').with_value('MyDomain')
      end
    end

    context 'with authtoken defaults' do
      let :pre_condition do
        "class { 'heat::keystone::authtoken':
           password => 'heat_password',
         }"
      end

      let :params do
        {}
      end

      it 'configures trustee options' do
        is_expected.to contain_heat_config('trustee/password').with_value('heat_password').with_secret(true)
        is_expected.to contain_heat_config('trustee/auth_url').with_value('http://127.0.0.1:5000/')
        is_expected.to contain_heat_config('trustee/auth_type').with_value('password')
        is_expected.to contain_heat_config('trustee/username').with_value('heat')
        is_expected.to contain_heat_config('trustee/user_domain_name').with_value('Default')
      end
    end

    context 'with authtoken parameters' do
      let :pre_condition do
        "class { 'heat::keystone::authtoken':
           password         => 'heat_password',
           auth_type        => 'v3password',
           auth_url         => 'https://localhost:13000/',
           username         => 'alt_heat',
           user_domain_name => 'MyDomain',
         }"
      end

      let :params do
        {}
      end

      it 'configures trustee options' do
        is_expected.to contain_heat_config('trustee/password').with_value('heat_password').with_secret(true)
        is_expected.to contain_heat_config('trustee/auth_url').with_value('https://localhost:13000/')
        is_expected.to contain_heat_config('trustee/auth_type').with_value('v3password')
        is_expected.to contain_heat_config('trustee/username').with_value('alt_heat')
        is_expected.to contain_heat_config('trustee/user_domain_name').with_value('MyDomain')
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'heat::trustee'
    end
  end

end
