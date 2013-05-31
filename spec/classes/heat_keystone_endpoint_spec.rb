require 'spec_helper'

describe 'heat::keystone::auth' do

  let :params do
    {:password => 'heat_password'}
  end

  context 'with default parameters' do

    it { should contain_keystone_user('heat').with(
      :ensure   => 'present',
      :password => 'heat_password'
    ) }

    it { should contain_keystone_user_role('heat@services').with(
      :ensure => 'present',
      :roles  => 'admin'
    )}

    it { should contain_keystone_service('heat').with(
      :ensure => 'present',
      :type        => 'orchestration',
      :description => 'Heat Service'
    )}

    it { should contain_keystone_service('heat_cfn').with(
      :ensure => 'present',
      :type        => 'cloudformation',
      :description => 'Heat CloudFormation Service'
    )}

    it { should contain_keystone_endpoint('RegionOne/heat').with(
      :ensure       => 'present',
      :public_url   => 'http://127.0.0.1:8004/v1',
      :admin_url    => 'http://127.0.0.1:8004/v1',
      :internal_url => 'http://127.0.0.1:8004/v1',
    )}

    it { should contain_keystone_endpoint('RegionOne/heat-cfn').with(
      :ensure       => 'present',
      :public_url   => 'http://127.0.0.1:8000/v1/$(tenant_id)s',
      :admin_url    => 'http://127.0.0.1:8000/v1/$(tenant_id)s',
      :internal_url => 'http://127.0.0.1:8000/v1/$(tenant_id)s',
    )}

  end

  context 'when setting auth name' do
    before do
      params.merge!( :auth_name => 'foo' )
    end

    it { should contain_keystone_user('foo').with(
      :ensure   => 'present',
      :password => 'heat_password'
    ) }

    it { should contain_keystone_user_role('foo@services').with(
      :ensure => 'present',
      :roles  => 'admin'
    )}

    it { should contain_keystone_service('foo').with(
      :ensure      => 'present',
      :type        => 'orchestration',
      :description => 'Heat Service'
    )}

    it { should contain_keystone_service('foo_cfn').with(
      :ensure      => 'present',
      :type        => 'cloudformation',
      :description => 'Heat CloudFormation Service'
    )}

  end

  describe 'when disabling CFN endpoint' do
    before do
      params.merge!( :configure_cfn_endpoint => false )
    end

    it { should_not contain_keystone_service('heat_cfn') }
    it { should_not contain_keystone_endpoint('RegionOne/heat_cfn') }
  end

end
