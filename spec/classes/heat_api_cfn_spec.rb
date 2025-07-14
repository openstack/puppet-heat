require 'spec_helper'

describe 'heat::api_cfn' do

  let :params do
    {
      :enabled        => true,
      :manage_service => true,
    }
  end

  shared_examples_for 'heat-api-cfn' do
    let :pre_condition do
      "class {'heat::keystone::authtoken':
         password => 'a_big_secret',
       }"
    end

    context 'config params' do

      it { is_expected.to contain_class('heat') }
      it { is_expected.to contain_class('heat::params') }
      it { is_expected.to contain_class('heat::policy') }

      it { is_expected.to contain_heat_config('heat_api_cfn/bind_host').with_ensure('absent') }
      it { is_expected.to contain_heat_config('heat_api_cfn/bind_port').with_ensure('absent') }
      it { is_expected.to contain_heat_config('heat_api_cfn/workers').with_ensure('absent') }
      it { is_expected.to contain_heat_config('heat_api_cfn/cert_file').with_ensure('absent') }
      it { is_expected.to contain_heat_config('heat_api_cfn/key_file').with_ensure('absent') }
    end

    [{:enabled => true}, {:enabled => false}].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures heat-api-cfn service' do

          is_expected.to contain_service('heat-api-cfn').with(
            :ensure     => (params[:manage_service] && params[:enabled]) ? 'running' : 'stopped',
            :name       => platform_params[:api_cfn_service_name],
            :enable     => params[:enabled],
            :hasstatus  => true,
            :hasrestart => true,
            :tag        => 'heat-service',
          )
          is_expected.to contain_service('heat-api-cfn').that_subscribes_to(nil)
        end
      end
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it 'does not configure heat-api-cfn service' do
        is_expected.to_not contain_service('heat-api-cfn')
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

      let :platform_params do
        case facts[:os]['family']
        when 'Debian'
          { :api_cfn_service_name => 'heat-api-cfn' }
        when 'RedHat'
          { :api_cfn_service_name => 'openstack-heat-api-cfn' }
        end
      end

      it_behaves_like 'heat-api-cfn'
    end
  end

end
