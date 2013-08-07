require 'spec_helper'

describe 'heat' do

  let :params do
    {
      :package_ensure     => 'present',
      :verbose            => 'False',
      :debug              => 'False',
      :rabbit_host        => '127.0.0.1',
      :rabbit_port        => 5672,
      :rabbit_userid      => 'guest',
      :rabbit_password    => '',
      :rabbit_virtualhost => '/',
    }
  end

  shared_examples_for 'heat' do

    context 'with rabbit_host parameter' do
      it_configures 'a heat base installation'
      it_configures 'rabbit without HA support (with backward compatibility)'
    end

    context 'with rabbit_hosts parameter' do
      context 'with one server' do
        before { params.merge!( :rabbit_hosts => ['127.0.0.1:5672'] ) }
        it_configures 'a heat base installation'
        it_configures 'rabbit without HA support (without backward compatibility)'
      end

      context 'with multiple servers' do
        before { params.merge!( :rabbit_hosts => ['rabbit1:5672', 'rabbit2:5672'] ) }
        it_configures 'a heat base installation'
        it_configures 'rabbit with HA support'
      end
    end
  end

  shared_examples_for 'a heat base installation' do

    it { should include_class('heat::params') }

    it 'configures heat group' do
      should contain_group('heat').with(
        :name    => 'heat',
        :require => 'Package[heat-common]'
      )
    end

    it 'configures heat user' do
      should contain_user('heat').with(
        :name    => 'heat',
        :gid     => 'heat',
        :groups  => ['heat'],
        :system  => true,
        :require => 'Package[heat-common]'
      )
    end

    it 'configures heat configuration folder' do
      should contain_file('/etc/heat/').with(
        :ensure  => 'directory',
        :owner   => 'heat',
        :group   => 'heat',
        :mode    => '0750',
        :require => 'Package[heat-common]'
      )
    end

    it 'configures heat configuration file' do
      should contain_file('/etc/heat/heat.conf').with(
        :owner   => 'heat',
        :group   => 'heat',
        :mode    => '0640',
        :require => 'Package[heat-common]'
      )
    end

    it 'installs heat common package' do
      should contain_package('heat-common').with(
        :ensure => 'present',
        :name   => platform_params[:common_package_name]
      )
    end

    it 'configures rabbit' do
      should contain_heat_config('DEFAULT/rabbit_userid').with_value( params[:rabbit_userid] )
      should contain_heat_config('DEFAULT/rabbit_password').with_value( params[:rabbit_password] )
      should contain_heat_config('DEFAULT/rabbit_virtualhost').with_value( params[:rabbit_virtualhost] )
    end

    it 'configures debug and verbose' do
      should contain_heat_config('DEFAULT/debug').with_value( params[:debug] )
      should contain_heat_config('DEFAULT/verbose').with_value( params[:verbose] )
    end

  end

  shared_examples_for 'rabbit without HA support (with backward compatibility)' do
    it { should contain_heat_config('DEFAULT/rabbit_host').with_value( params[:rabbit_host] ) }
    it { should contain_heat_config('DEFAULT/rabbit_port').with_value( params[:rabbit_port] ) }
    it { should contain_heat_config('DEFAULT/rabbit_hosts').with_value( "#{params[:rabbit_host]}:#{params[:rabbit_port]}" ) }
    it { should contain_heat_config('DEFAULT/rabbit_ha_queues').with_value('false') }
  end

  shared_examples_for 'rabbit without HA support (without backward compatibility)' do
    it { should contain_heat_config('DEFAULT/rabbit_host').with_ensure('absent') }
    it { should contain_heat_config('DEFAULT/rabbit_port').with_ensure('absent') }
    it { should contain_heat_config('DEFAULT/rabbit_hosts').with_value( params[:rabbit_hosts].join(',') ) }
    it { should contain_heat_config('DEFAULT/rabbit_ha_queues').with_value('false') }
  end

  shared_examples_for 'rabbit with HA support' do
    it { should contain_heat_config('DEFAULT/rabbit_host').with_ensure('absent') }
    it { should contain_heat_config('DEFAULT/rabbit_port').with_ensure('absent') }
    it { should contain_heat_config('DEFAULT/rabbit_hosts').with_value( params[:rabbit_hosts].join(',') ) }
    it { should contain_heat_config('DEFAULT/rabbit_ha_queues').with_value('true') }
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :common_package_name => 'heat-common' }
    end

    it_configures 'heat'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :common_package_name => 'openstack-heat-common' }
    end

    it_configures 'heat'
  end
end
