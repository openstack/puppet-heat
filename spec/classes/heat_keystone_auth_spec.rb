#
# Unit tests for heat::keystone::auth
#

require 'spec_helper'

describe 'heat::keystone::auth' do
  shared_examples_for 'heat::keystone::auth' do
    context 'with default class parameters' do
      let :params do
        { :password => 'heat_password' }
      end

      it { is_expected.to contain_keystone__resource__service_identity('heat').with(
        :configure_user      => true,
        :configure_user_role => true,
        :configure_endpoint  => true,
        :service_name        => 'heat',
        :service_type        => 'orchestration',
        :service_description => 'OpenStack Orchestration Service',
        :region              => 'RegionOne',
        :auth_name           => 'heat',
        :password            => 'heat_password',
        :email               => 'heat@localhost',
        :tenant              => 'services',
        :roles               => ['admin'],
        :system_scope        => 'all',
        :system_roles        => [],
        :public_url          => 'http://127.0.0.1:8004/v1/%(tenant_id)s',
        :internal_url        => 'http://127.0.0.1:8004/v1/%(tenant_id)s',
        :admin_url           => 'http://127.0.0.1:8004/v1/%(tenant_id)s',
      ) }

      it { is_expected.to contain_keystone_role('heat_stack_user').with_ensure('present') }
      it { is_expected.to_not contain_keystone_role('heat_stack_owner').with_ensure('present') }
    end

    context 'when overriding parameters' do
      let :params do
        { :password                  => 'heat_password',
          :auth_name                 => 'alt_heat',
          :email                     => 'alt_heat@alt_localhost',
          :tenant                    => 'alt_service',
          :roles                     => ['admin', 'service'],
          :system_scope              => 'alt_all',
          :system_roles              => ['admin', 'member', 'reader'],
          :configure_endpoint        => false,
          :configure_user            => false,
          :configure_user_role       => false,
          :service_description       => 'Alternative OpenStack Orchestration Service',
          :service_name              => 'alt_service',
          :service_type              => 'alt_orchestration',
          :region                    => 'RegionTwo',
          :public_url                => 'https://10.10.10.10:80',
          :internal_url              => 'http://10.10.10.11:81',
          :admin_url                 => 'http://10.10.10.12:81',
          :heat_stack_user_role      => 'alt_heat_stack_user',
          :configure_delegated_roles => true,
          :trusts_delegated_roles    => ['alt_heat_stack_owner'] }
      end

      it { is_expected.to contain_keystone__resource__service_identity('heat').with(
        :configure_user      => false,
        :configure_user_role => false,
        :configure_endpoint  => false,
        :service_name        => 'alt_service',
        :service_type        => 'alt_orchestration',
        :service_description => 'Alternative OpenStack Orchestration Service',
        :region              => 'RegionTwo',
        :auth_name           => 'alt_heat',
        :password            => 'heat_password',
        :email               => 'alt_heat@alt_localhost',
        :tenant              => 'alt_service',
        :roles               => ['admin', 'service'],
        :system_scope        => 'alt_all',
        :system_roles        => ['admin', 'member', 'reader'],
        :public_url          => 'https://10.10.10.10:80',
        :internal_url        => 'http://10.10.10.11:81',
        :admin_url           => 'http://10.10.10.12:81',
      ) }

      it { is_expected.to contain_keystone_role('alt_heat_stack_user').with_ensure('present') }
      it { is_expected.to contain_keystone_role('alt_heat_stack_owner').with_ensure('present') }
    end

    context 'when role management parameters overridden' do
      let :params do
        { :password                    => 'heat_password',
          :configure_delegated_roles   => true,
          :manage_heat_stack_user_role => false }
      end

      it { is_expected.to_not contain_keystone_role('heat_stack_user').with_ensure('present') }
      it { is_expected.to contain_keystone_role('heat_stack_owner').with_ensure('present') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'heat::keystone::auth'
    end
  end
end
