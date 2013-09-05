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
      :sql_connection     => 'mysql://user@host/database'
    }
  end

  let :qpid_params do
    {
      :rpc_backend   => "heat.openstack.common.rpc.impl_qpid",
      :qpid_hostname => 'localhost',
      :qpid_port     => 5672,
      :qpid_username => 'guest',
      :qpid_password  => 'guest',
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

    context 'with qpid instance' do
      before {params.merge!(qpid_params) }

      it_configures 'a heat base installation'
      it_configures 'qpid as rpc backend'
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


    it 'configures debug and verbose' do
      should contain_heat_config('DEFAULT/debug').with_value( params[:debug] )
      should contain_heat_config('DEFAULT/verbose').with_value( params[:verbose] )
    end

    it 'configures sql_connection' do
      should contain_heat_config('DEFAULT/sql_connection').with_value( params[:sql_connection] )
    end

    context("failing if sql_connection is invalid") do
      before { params[:sql_connection] = 'foo://foo:bar@baz/moo' }
      it { expect { should raise_error(Puppet::Error) } }
    end

  end

  shared_examples_for 'rabbit without HA support (with backward compatibility)' do
    it 'configures rabbit' do
      should contain_heat_config('DEFAULT/rabbit_userid').with_value( params[:rabbit_userid] )
      should contain_heat_config('DEFAULT/rabbit_password').with_value( params[:rabbit_password] )
      should contain_heat_config('DEFAULT/rabbit_virtualhost').with_value( params[:rabbit_virtualhost] )
    end
    it { should contain_heat_config('DEFAULT/rabbit_host').with_value( params[:rabbit_host] ) }
    it { should contain_heat_config('DEFAULT/rabbit_port').with_value( params[:rabbit_port] ) }
    it { should contain_heat_config('DEFAULT/rabbit_hosts').with_value( "#{params[:rabbit_host]}:#{params[:rabbit_port]}" ) }
    it { should contain_heat_config('DEFAULT/rabbit_ha_queues').with_value('false') }
  end

  shared_examples_for 'rabbit without HA support (without backward compatibility)' do
    it 'configures rabbit' do
      should contain_heat_config('DEFAULT/rabbit_userid').with_value( params[:rabbit_userid] )
      should contain_heat_config('DEFAULT/rabbit_password').with_value( params[:rabbit_password] )
      should contain_heat_config('DEFAULT/rabbit_virtualhost').with_value( params[:rabbit_virtualhost] )
    end
    it { should contain_heat_config('DEFAULT/rabbit_host').with_ensure('absent') }
    it { should contain_heat_config('DEFAULT/rabbit_port').with_ensure('absent') }
    it { should contain_heat_config('DEFAULT/rabbit_hosts').with_value( params[:rabbit_hosts].join(',') ) }
    it { should contain_heat_config('DEFAULT/rabbit_ha_queues').with_value('false') }
  end

  shared_examples_for 'rabbit with HA support' do
    it 'configures rabbit' do
      should contain_heat_config('DEFAULT/rabbit_userid').with_value( params[:rabbit_userid] )
      should contain_heat_config('DEFAULT/rabbit_password').with_value( params[:rabbit_password] )
      should contain_heat_config('DEFAULT/rabbit_virtualhost').with_value( params[:rabbit_virtualhost] )
    end
    it { should contain_heat_config('DEFAULT/rabbit_host').with_ensure('absent') }
    it { should contain_heat_config('DEFAULT/rabbit_port').with_ensure('absent') }
    it { should contain_heat_config('DEFAULT/rabbit_hosts').with_value( params[:rabbit_hosts].join(',') ) }
    it { should contain_heat_config('DEFAULT/rabbit_ha_queues').with_value('true') }
  end


  shared_examples_for 'qpid as rpc backend' do
    context("with default parameters") do
      it { should contain_heat_config('DEFAULT/qpid_reconnect').with_value(true) }
      it { should contain_heat_config('DEFAULT/qpid_reconnect_timeout').with_value('0') }
      it { should contain_heat_config('DEFAULT/qpid_reconnect_limit').with_value('0') }
      it { should contain_heat_config('DEFAULT/qpid_reconnect_interval_min').with_value('0') }
      it { should contain_heat_config('DEFAULT/qpid_reconnect_interval_max').with_value('0') }
      it { should contain_heat_config('DEFAULT/qpid_reconnect_interval').with_value('0') }
      it { should contain_heat_config('DEFAULT/qpid_heartbeat').with_value('60') }
      it { should contain_heat_config('DEFAULT/qpid_protocol').with_value('tcp') }
      it { should contain_heat_config('DEFAULT/qpid_tcp_nodelay').with_value(true) }
      end

    context("with mandatory parameters set") do
      it { should contain_heat_config('DEFAULT/rpc_backend').with_value('heat.openstack.common.rpc.impl_qpid') }
      it { should contain_heat_config('DEFAULT/qpid_hostname').with_value( params[:qpid_hostname] ) }
      it { should contain_heat_config('DEFAULT/qpid_port').with_value( params[:qpid_port] ) }
      it { should contain_heat_config('DEFAULT/qpid_username').with_value( params[:qpid_username]) }
      it { should contain_heat_config('DEFAULT/qpid_password').with_value(params[:qpid_password]) }
    end

    context("failing if the rpc_backend is not present") do
      before { params.delete( :rpc_backend) }
      it { expect { should raise_error(Puppet::Error) } }
    end
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
