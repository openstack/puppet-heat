#
# Unit tests for heat::keystone::auth_cfn
#

require 'spec_helper'

describe 'heat::keystone::auth_cfn' do
  shared_examples_for 'heat::keystone::auth_cfn' do
    context 'with default class parameters' do
      it { is_expected.to contain_keystone__resource__service_identity('heat-cfn').with(
        :configure_user      => false,
        :configure_user_role => false,
        :configure_endpoint  => true,
        :service_name        => 'heat-cfn',
        :service_type        => 'cloudformation',
        :service_description => 'OpenStack Cloudformation Service',
        :region              => 'RegionOne',
        :public_url          => 'http://127.0.0.1:8000/v1',
        :internal_url        => 'http://127.0.0.1:8000/v1',
        :admin_url           => 'http://127.0.0.1:8000/v1',
      ) }
    end

    context 'when overriding parameters' do
      let :params do
        {
          :configure_endpoint  => false,
          :configure_service   => false,
          :service_description => 'Alternative OpenStack Cloudformation Service',
          :service_name        => 'alt_service',
          :service_type        => 'alt_cloudformation',
          :region              => 'RegionTwo',
          :public_url          => 'https://10.10.10.10:80',
          :internal_url        => 'http://10.10.10.11:81',
          :admin_url           => 'http://10.10.10.12:81'
        }
      end

      it { is_expected.to contain_keystone__resource__service_identity('heat-cfn').with(
        :configure_user      => false,
        :configure_user_role => false,
        :configure_endpoint  => false,
        :configure_service   => false,
        :service_name        => 'alt_service',
        :service_type        => 'alt_cloudformation',
        :service_description => 'Alternative OpenStack Cloudformation Service',
        :region              => 'RegionTwo',
        :public_url          => 'https://10.10.10.10:80',
        :internal_url        => 'http://10.10.10.11:81',
        :admin_url           => 'http://10.10.10.12:81',
      ) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'heat::keystone::auth_cfn'
    end
  end
end
