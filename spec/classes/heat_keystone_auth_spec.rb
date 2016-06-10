require 'spec_helper'

describe 'heat::keystone::auth' do

  let :params do
    {:password => 'heat-passw0rd'}
  end

  shared_examples_for 'heat keystone auth' do

    context 'without the required password parameter' do
      before { params.delete(:password) }
      it { expect { is_expected.to raise_error(Puppet::Error) } }
    end

    context 'with service disabled' do
      before do
        params.merge!({:configure_service => false})
      end
      it { is_expected.to_not contain_keystone_service('heat::orchestration') }
    end

    context 'with overridden parameters' do
      before do
        params.merge!({
          :password                  => 'heat-passw0rd',
          :email                     => 'heat@localhost',
          :auth_name                 => 'heat',
          :configure_endpoint        => true,
          :service_type              => 'orchestration',
          :region                    => 'RegionOne',
          :tenant                    => 'services',
          :configure_user_role       => true,
          :public_url                => 'http://127.0.0.1:8004/v1/%(tenant_id)s',
          :admin_url                 => 'http://127.0.0.1:8004/v1/%(tenant_id)s',
          :internal_url              => 'http://127.0.0.1:8004/v1/%(tenant_id)s',
          :configure_delegated_roles => false,
          :heat_stack_user_role      => 'HeatUser::foobaz@::foobaz',
        })
      end

      it 'configures heat user' do
        is_expected.to contain_keystone_user( params[:auth_name] ).with(
          :ensure   => 'present',
          :password => params[:password],
          :email    => params[:email],
        )
      end

      it 'configures heat user roles' do
        is_expected.to contain_keystone_user_role("#{params[:auth_name]}@#{params[:tenant]}").with(
          :ensure  => 'present',
          :roles   => ['admin']
        )
      end

      it 'configures heat stack_user role' do
        is_expected.to contain_keystone_role("HeatUser::foobaz@::foobaz").with(
          :ensure  => 'present'
        )
      end

      it 'configures heat service' do
        is_expected.to contain_keystone_service("#{params[:auth_name]}::#{params[:service_type]}").with(
          :ensure      => 'present',
          :description => 'Openstack Orchestration Service'
        )
      end

      it 'configure heat endpoints' do
        is_expected.to contain_keystone_endpoint("#{params[:region]}/#{params[:auth_name]}::#{params[:service_type]}").with(
          :ensure       => 'present',
          :public_url   => params[:public_url],
          :admin_url    => params[:admin_url],
          :internal_url => params[:internal_url]
        )
      end
    end

    context 'when overriding auth and service name' do
      before do
        params.merge!({
          :auth_name => 'heaty',
          :service_name => 'heaty'
        })
      end
      it 'configures correct user name' do
        is_expected.to contain_keystone_user('heaty')
      end
      it 'configures correct user role' do
        is_expected.to contain_keystone_user_role('heaty@services')
      end
      it 'configures correct service name' do
        is_expected.to contain_keystone_service('heaty::orchestration')
      end
      it 'configures correct endpoint name' do
        is_expected.to contain_keystone_endpoint('RegionOne/heaty::orchestration')
      end
    end

    context 'when disabling user configuration' do
      before do
        params.merge!( :configure_user => false )
      end

      it { is_expected.to_not contain_keystone_user('heat') }
      it { is_expected.to contain_keystone_user_role('heat@services') }

      it { is_expected.to contain_keystone_service('heat::orchestration').with(
        :ensure       => 'present',
        :description  => 'Openstack Orchestration Service'
      )}
    end

    context 'when disabling user and role configuration' do
      before do
        params.merge!(
          :configure_user       => false,
          :configure_user_role  => false
        )
      end

      it { is_expected.to_not contain_keystone_user('heat') }
      it { is_expected.to_not contain_keystone_user_role('heat@services') }

      it { is_expected.to contain_keystone_service('heat::orchestration').with(
        :ensure       => 'present',
        :description  => 'Openstack Orchestration Service'
      )}
    end

    context 'when configuring delegated roles' do
      before do
        params.merge!({
          :configure_delegated_roles => true,
        })
      end
      it 'configures delegated roles' do
        is_expected.to contain_keystone_role("heat_stack_owner").with(
          :ensure  => 'present'
        )
      end
    end

    context 'when not managing heat_stack_user_role' do
      before do
        params.merge!({
          :heat_stack_user_role        => 'HeatUser::foobaz@::foobaz',
          :manage_heat_stack_user_role => false
        })
      end

      it 'doesnt manage the heat_stack_user_role' do
        is_expected.to_not contain_keystone_user_role(params[:heat_stack_user_role])
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily => 'Debian',
      })
    end

    it_configures 'heat keystone auth'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily => 'RedHat',
      })
    end

    it_configures 'heat keystone auth'
  end
end
