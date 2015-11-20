require 'spec_helper'

describe 'heat::keystone::domain' do

  let :params do {
    :domain_name        => 'heat',
    :domain_admin       => 'heat_admin',
    :domain_admin_email => 'heat_admin@localhost',
    :domain_password    => 'domain_passwd'
    }
  end

  shared_examples_for 'heat keystone domain' do
    it 'configure heat.conf' do
      is_expected.to contain_heat_config('DEFAULT/stack_domain_admin').with_value(params[:domain_admin])
      is_expected.to contain_heat_config('DEFAULT/stack_domain_admin_password').with_value(params[:domain_password])
      is_expected.to contain_heat_config('DEFAULT/stack_domain_admin_password').with_secret(true)
      is_expected.to contain_heat_config('DEFAULT/stack_user_domain_name').with_value(params[:domain_name])
    end

    it 'should create keystone domain' do
      is_expected.to contain_keystone_domain(params[:domain_name]).with(
        :ensure  => 'present',
        :enabled => 'true',
        :name    => params[:domain_name]
      )

      is_expected.to contain_keystone_user("#{params[:domain_admin]}::#{params[:domain_name]}").with(
        :ensure   => 'present',
        :enabled  => 'true',
        :email    => params[:domain_admin_email],
        :password => params[:domain_password],
      )
      is_expected.to contain_keystone_user_role("#{params[:domain_admin]}::#{params[:domain_name]}@::#{params[:domain_name]}").with(
        :roles => ['admin'],
      )
    end

    context 'when not managing the domain creation' do
      before do
        params.merge!(
          :manage_domain => false
        )
      end

      it { is_expected.to_not contain_keystone_domain('heat_domain') }
    end

    context 'when not managing the user creation' do
      before do
        params.merge!(
          :manage_user => false
        )
      end

      it { is_expected.to_not contain_keystone_user("#{params[:domain_admin]}::#{params[:domain_name]}") }
    end

    context 'when not managing the user role creation' do
      before do
        params.merge!(
          :manage_role => false
        )
      end

      it { is_expected.to_not contain_keystone_user_role("#{params[:domain_admin]}::#{params[:domain_name]}@::#{params[:domain_name]}") }
    end
  end


  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily => 'Debian',
      })
    end

    it_configures 'heat keystone domain'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily => 'RedHat',
      })
    end

    it_configures 'heat keystone domain'
  end
end
