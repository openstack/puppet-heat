require 'spec_helper'

describe 'heat::ec2authtoken' do
  shared_examples 'heat::ec2authtoken' do
    let :params do
      {
        :password => 'heat_password',
      }
    end

    context 'with defaults' do
      it 'configures defaults' do
        is_expected.to contain_heat_config('ec2authtoken/password').with_value('heat_password').with_secret(true)
        is_expected.to contain_heat_config('ec2authtoken/username').with_value('heat')
        is_expected.to contain_heat_config('ec2authtoken/auth_url').with_value('http://127.0.0.1:5000')
        is_expected.to contain_heat_config('ec2authtoken/project_name').with_value('services')
        is_expected.to contain_heat_config('ec2authtoken/project_domain_name').with_value('Default')
        is_expected.to contain_heat_config('ec2authtoken/user_domain_name').with_value('Default')
        is_expected.to contain_heat_config('ec2authtoken/system_scope').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('ec2authtoken/auth_type').with_value('password')
        is_expected.to contain_heat_config('ec2authtoken/insecure').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('ec2authtoken/cafile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('ec2authtoken/certfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('ec2authtoken/keyfile').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('ec2authtoken/region_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('ec2authtoken/valid_interfaces').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('ec2authtoken/service_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('ec2authtoken/service_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('ec2authtoken/timeout').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with parameters' do
      before :each do
        params.merge!({
          :username            => 'alt_heat',
          :auth_url            => 'http://localhost:5000',
          :project_name        => 'alt_services',
          :project_domain_name => 'ProjectDomain',
          :user_domain_name    => 'UserDomain',
          :auth_type           => 'v3password',
          :insecure            => false,
          :cafile              => 'cafile.pem',
          :certfile            => 'certfile.crt',
          :keyfile             => 'keyfile',
          :region_name         => 'regionOne',
          :valid_interfaces    => ['internal', 'public'],
          :service_name        => 'keystone',
          :service_type        => 'identity',
          :timeout             => 60,
        })
      end

      it 'configures client parameters' do
        is_expected.to contain_heat_config('ec2authtoken/password').with_value('heat_password').with_secret(true)
        is_expected.to contain_heat_config('ec2authtoken/username').with_value('alt_heat')
        is_expected.to contain_heat_config('ec2authtoken/auth_url').with_value('http://localhost:5000')
        is_expected.to contain_heat_config('ec2authtoken/project_name').with_value('alt_services')
        is_expected.to contain_heat_config('ec2authtoken/project_domain_name').with_value('ProjectDomain')
        is_expected.to contain_heat_config('ec2authtoken/user_domain_name').with_value('UserDomain')
        is_expected.to contain_heat_config('ec2authtoken/system_scope').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('ec2authtoken/auth_type').with_value('v3password')
        is_expected.to contain_heat_config('ec2authtoken/insecure').with_value(false)
        is_expected.to contain_heat_config('ec2authtoken/cafile').with_value('cafile.pem')
        is_expected.to contain_heat_config('ec2authtoken/certfile').with_value('certfile.crt')
        is_expected.to contain_heat_config('ec2authtoken/keyfile').with_value('keyfile')
        is_expected.to contain_heat_config('ec2authtoken/region_name').with_value('regionOne')
        is_expected.to contain_heat_config('ec2authtoken/valid_interfaces').with_value('internal,public')
        is_expected.to contain_heat_config('ec2authtoken/service_name').with_value('keystone')
        is_expected.to contain_heat_config('ec2authtoken/service_type').with_value('identity')
        is_expected.to contain_heat_config('ec2authtoken/timeout').with_value(60)
      end
    end

    context 'with system scope' do
      before :each do
        params.merge!({
          :system_scope => 'all',
        })
      end

      it 'configures system scope credential' do
        is_expected.to contain_heat_config('ec2authtoken/project_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('ec2authtoken/project_domain_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('ec2authtoken/system_scope').with_value('all')
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'heat::ec2authtoken'
    end
  end
end
