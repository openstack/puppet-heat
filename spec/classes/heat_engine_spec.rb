require 'spec_helper'

describe 'heat::engine' do

  let :default_params do
    { :enabled                             => true,
      :manage_service                      => true,
      :heat_stack_user_role                => '<SERVICE DEFAULT>',
      :heat_metadata_server_url            => 'http://127.0.0.1:8000',
      :heat_waitcondition_server_url       => 'http://127.0.0.1:8000/v1/waitcondition',
      :heat_watch_server_url               => 'http://128.0.0.1:8003',
      :engine_life_check_timeout           => '<SERVICE DEFAULT>',
      :trusts_delegated_roles              => ['heat_stack_owner'],
      :deferred_auth_method                => '<SERVICE DEFAULT>',
      :default_software_config_transport   => '<SERVICE DEFAULT>',
      :default_deployment_signal_transport => '<SERVICE DEFAULT>',
      :convergence_engine                  => '<SERVICE DEFAULT>',
      :environment_dir                     => '<SERVICE DEFAULT>',
      :template_dir                        => '<SERVICE DEFAULT>',
    }
  end

  shared_examples_for 'heat-engine' do
    let :pre_condition do
      "class { 'heat::keystone::authtoken':
         password => 'password',
       }"
    end

    [
      {},
      { :auth_encryption_key                 => '1234567890AZERTYUIOPMLKJHGFDSQ12' },
      { :auth_encryption_key                 => '0234567890AZERTYUIOPMLKJHGFDSQ24',
        :enabled                             => false,
        :heat_stack_user_role                => 'heat_stack_user',
        :heat_metadata_server_url            => 'http://127.0.0.1:8000',
        :heat_waitcondition_server_url       => 'http://127.0.0.1:8000/v1/waitcondition',
        :heat_watch_server_url               => 'http://128.0.0.1:8003',
        :engine_life_check_timeout           => '2',
        :trusts_delegated_roles              => ['role1', 'role2'],
        :deferred_auth_method                => 'trusts',
        :default_software_config_transport   => 'POLL_SERVER_CFN',
        :default_deployment_signal_transport => 'CFN_SIGNAL',
        :num_engine_workers                  => '4',
        :convergence_engine                  => false,
        :environment_dir                     => '/etc/heat/environment.d',
        :template_dir                        => '/etc/heat/templates',
      }
    ].each do |new_params|
      describe 'when #{param_set == {} ? "using default" : "specifying"} parameters'

      let :params do
        new_params
      end

      let :expected_params do
        default_params.merge(params)
      end

      it { is_expected.to contain_package('heat-engine').with(
        :ensure => 'present',
        :name   => os_params[:package_name],
        :tag    => ['openstack', 'heat-package'],
      ) }

      it { is_expected.to contain_service('heat-engine').with(
        :ensure     => (expected_params[:manage_service] && expected_params[:enabled]) ? 'running' : 'stopped',
        :name       => os_params[:service_name],
        :enable     => expected_params[:enabled],
        :hasstatus  => 'true',
        :hasrestart => 'true',
        :tag        => 'heat-service',
      ) }

      it { is_expected.to contain_heat_config('DEFAULT/auth_encryption_key').with_value( expected_params[:auth_encryption_key] ) }
      it { is_expected.to contain_heat_config('DEFAULT/heat_stack_user_role').with_value( expected_params[:heat_stack_user_role] ) }
      it { is_expected.to contain_heat_config('DEFAULT/heat_metadata_server_url').with_value( expected_params[:heat_metadata_server_url] ) }
      it { is_expected.to contain_heat_config('DEFAULT/heat_waitcondition_server_url').with_value( expected_params[:heat_waitcondition_server_url] ) }
      it { is_expected.to contain_heat_config('DEFAULT/heat_watch_server_url').with_value( expected_params[:heat_watch_server_url] ) }
      it { is_expected.to contain_heat_config('DEFAULT/engine_life_check_timeout').with_value( expected_params[:engine_life_check_timeout] ) }
      it { is_expected.to contain_heat_config('DEFAULT/trusts_delegated_roles').with_value( expected_params[:trusts_delegated_roles] ) }
      it { is_expected.to contain_heat_config('DEFAULT/deferred_auth_method').with_value( expected_params[:deferred_auth_method] ) }
      it { is_expected.to contain_heat_config('DEFAULT/default_software_config_transport').with_value( expected_params[:default_software_config_transport] ) }
      it { is_expected.to contain_heat_config('DEFAULT/default_deployment_signal_transport').with_value( expected_params[:default_deployment_signal_transport] ) }
      it { is_expected.to contain_heat_config('DEFAULT/instance_connection_is_secure').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('DEFAULT/instance_connection_https_validate_certificates').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('DEFAULT/max_resources_per_stack').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('DEFAULT/num_engine_workers').with_value( expected_params[:num_engine_workers] ) }
      it { is_expected.to contain_heat_config('DEFAULT/convergence_engine').with_value( expected_params[:convergence_engine] ) }
      it { is_expected.to contain_heat_config('DEFAULT/environment_dir').with_value( expected_params[:environment_dir] ) }
      it { is_expected.to contain_heat_config('DEFAULT/template_dir').with_value( expected_params[:template_dir] ) }
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it { is_expected.to contain_service('heat-engine').with(
        :ensure     => nil,
        :name       => os_params[:service_name],
        :enable     => false,
        :hasstatus  => 'true',
        :hasrestart => 'true',
        :tag        => 'heat-service',
      ) }
    end
    context 'with wrong auth_encryption_key parameter size' do
      before do
        params.merge!({
          :auth_encryption_key => 'hello' })
      end
      it_raises 'a Puppet::Error', /5 is not a correct size for auth_encryption_key parameter, it must be either 16, 24, 32 bytes long./
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily => 'Debian',
      })
    end

    let :os_params do
      { :package_name => 'heat-engine',
        :service_name => 'heat-engine'
      }
    end

    it_configures 'heat-engine'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily => 'RedHat',
      })
    end

    let :os_params do
      { :package_name => 'openstack-heat-engine',
        :service_name => 'openstack-heat-engine'
      }
    end

    it_configures 'heat-engine'
  end
end
