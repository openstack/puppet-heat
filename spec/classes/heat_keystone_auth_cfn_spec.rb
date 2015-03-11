require 'spec_helper'

describe 'heat::keystone::auth_cfn' do

  let :params do
    {
      :password           => 'heat-passw0rd',
      :email              => 'heat-cfn@localhost',
      :auth_name          => 'heat-cfn',
      :configure_endpoint => true,
      :configure_service  => true,
      :service_type       => 'cloudformation',
      :public_address     => '127.0.0.1',
      :admin_address      => '127.0.0.1',
      :internal_address   => '127.0.0.1',
      :port               => '8000',
      :version            => 'v1',
      :region             => 'RegionOne',
      :tenant             => 'services',
      :public_protocol    => 'http',
      :admin_protocol     => 'http',
      :internal_protocol  => 'http',
    }
  end

  shared_examples_for 'heat keystone auth' do

    context 'without the required password parameter' do
      before { params.delete(:password) }
      it { expect { is_expected.to raise_error(Puppet::Error) } }
    end

    it 'configures heat user' do
      is_expected.to contain_keystone_user( params[:auth_name] ).with(
        :ensure   => 'present',
        :password => params[:password],
        :email    => params[:email],
        :tenant   => params[:tenant]
      )
    end

    it 'configures heat user roles' do
      is_expected.to contain_keystone_user_role("#{params[:auth_name]}@#{params[:tenant]}").with(
        :ensure  => 'present',
        :roles   => ['admin']
      )
    end

    it 'configures heat service' do
      is_expected.to contain_keystone_service( params[:auth_name] ).with(
        :ensure      => 'present',
        :type        => params[:service_type],
        :description => 'Openstack Cloudformation Service'
      )
    end

    it 'configure heat endpoints' do
      is_expected.to contain_keystone_endpoint("#{params[:region]}/#{params[:auth_name]}").with(
        :ensure       => 'present',
        :public_url   => "#{params[:public_protocol]}://#{params[:public_address]}:#{params[:port]}/#{params[:version]}/",
        :admin_url    => "#{params[:admin_protocol]}://#{params[:admin_address]}:#{params[:port]}/#{params[:version]}/",
        :internal_url => "#{params[:internal_protocol]}://#{params[:internal_address]}:#{params[:port]}/#{params[:version]}/"
      )
    end

    context 'with service disabled' do
      before do
        params.merge!({
          :configure_service => false
        })
      end
      it { should_not contain_keystone_service("#{params[:region]}/#{params[:auth_name]}") }
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'heat keystone auth'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'heat keystone auth'
  end

  context 'when overriding service name' do
    before do
      params.merge!({
        :service_name => 'heat-cfn_service'
      })
    end
    it 'configures correct user name' do
      is_expected.to contain_keystone_user('heat-cfn')
    end
    it 'configures correct user role' do
      is_expected.to contain_keystone_user_role('heat-cfn@services')
    end
    it 'configures correct service name' do
      is_expected.to contain_keystone_service('heat-cfn_service')
    end
    it 'configures correct endpoint name' do
      is_expected.to contain_keystone_endpoint('RegionOne/heat-cfn_service')
    end
  end

  context 'when disabling user configuration' do
    before do
      params.merge!( :configure_user => false )
    end

    it { is_expected.to_not contain_keystone_user('heat_cfn') }
    it { is_expected.to contain_keystone_user_role('heat-cfn@services') }

    it { is_expected.to contain_keystone_service('heat-cfn').with(
      :ensure       => 'present',
      :type         => 'cloudformation',
      :description  => 'Openstack Cloudformation Service'
    )}
  end

  context 'when disabling user and role configuration' do
    before do
      params.merge!(
        :configure_user       => false,
        :configure_user_role  => false
      )
    end

    it { is_expected.to_not contain_keystone_user('heat_cfn') }
    it { is_expected.to_not contain_keystone_user_role('heat-cfn@services') }

    it { is_expected.to contain_keystone_service('heat-cfn').with(
      :ensure       => 'present',
      :type         => 'cloudformation',
      :description  => 'Openstack Cloudformation Service'
    )}
  end

end
