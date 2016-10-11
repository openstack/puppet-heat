require 'spec_helper'

describe 'heat' do

  let :params do
    {
      :package_ensure        => 'present',
      :verbose               => 'False',
      :debug                 => 'False',
      :use_stderr            => 'True',
      :log_dir               => '/var/log/heat',
      :rabbit_host           => '<SERVICE DEFAULT>',
      :rabbit_port           => 5672,
      :rabbit_userid         => '<SERVICE DEFAULT>',
      :rabbit_password       => '<SERVICE DEFAULT>',
      :rabbit_virtual_host   => '<SERVICE DEFAULT>',
      :database_connection   => 'mysql+pymysql://user@host/database',
      :database_idle_timeout => 3600,
      :keystone_ec2_uri      => 'http://127.0.0.1:5000/v2.0/ec2tokens',
      :flavor                => 'keystone',
      :keystone_password     => 'secretpassword',
      :heat_clients_url      => '<SERVICE DEFAULT>',
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
        before { params.merge!(
          :rabbit_hosts => ['rabbit1:5672', 'rabbit2:5672'],
          :amqp_durable_queues => true) }
        it_configures 'a heat base installation'
        it_configures 'rabbit with HA support'
      end
    end

    context 'with rabbit heartbeat configured' do
      before { params.merge!(
        :rabbit_heartbeat_timeout_threshold => '60',
        :rabbit_heartbeat_rate => '10' ) }
      it_configures 'a heat base installation'
      it_configures 'rabbit with heartbeat configured'
    end

    it_configures 'with SSL enabled with kombu'
    it_configures 'with SSL enabled without kombu'
    it_configures 'with SSL disabled'
    it_configures 'with SSL wrongly configured'
    it_configures "with auth_plugin"
    it_configures 'with enable_stack_adopt and enable_stack_abandon set'
    it_configures 'with notification_driver set to a string'
  end

  shared_examples_for 'a heat base installation' do

    it { is_expected.to contain_class('heat::logging') }
    it { is_expected.to contain_class('heat::params') }

    it 'installs heat common package' do
      is_expected.to contain_package('heat-common').with(
        :ensure => 'present',
        :name   => platform_params[:common_package_name],
        :tag    => ['openstack', 'heat-package'],
      )
    end

    it 'has db_sync enabled' do
      is_expected.to contain_class('heat::db::sync')
    end

    it 'configures max_template_size' do
      is_expected.to contain_heat_config('DEFAULT/max_template_size').with_value('<SERVICE DEFAULT>')
    end

    it 'configures max_json_body_size' do
      is_expected.to contain_heat_config('DEFAULT/max_json_body_size').with_value('<SERVICE DEFAULT>')
    end

    it 'configures project_domain_id' do
      is_expected.to contain_heat_config('trustee/project_domain_id').with_value( 'default' )
    end

    it 'configures user_domain_id' do
      is_expected.to contain_heat_config('trustee/user_domain_id').with_value( 'default' )
    end

    it 'configures auth_plugin' do
      is_expected.to contain_heat_config('trustee/auth_plugin').with_value( 'password' )
    end

    it 'configures auth_url' do
      is_expected.to contain_heat_config('trustee/auth_url').with_value( 'http://127.0.0.1:35357/' )
    end

    it 'configures username' do
      is_expected.to contain_heat_config('trustee/username').with_value( 'heat' )
    end

    it 'configures ' do
      is_expected.to contain_heat_config('trustee/password').with_secret( true )
    end

    it 'configures auth_uri for clients_keystone' do
      is_expected.to contain_heat_config('clients_keystone/auth_uri').with_value( 'http://127.0.0.1:35357/' )
    end

    it 'configures keystone_ec2_uri' do
      is_expected.to contain_heat_config('ec2authtoken/auth_uri').with_value( params[:keystone_ec2_uri] )
    end

    it { is_expected.to contain_heat_config('paste_deploy/flavor').with_value('keystone') }

    it 'configures notification_driver' do
        is_expected.to contain_heat_config('DEFAULT/notification_driver').with_value('<SERVICE DEFAULT>')
    end

    it 'sets clients_heat url' do
      is_expected.to contain_heat_config('clients_heat/url').with_value('<SERVICE DEFAULT>')
    end

    it_configures "with default auth method"
  end

  shared_examples_for 'rabbit without HA support (with backward compatibility)' do
    it 'configures rabbit' do
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_userid').with_value( params[:rabbit_userid] )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_password').with_value( params[:rabbit_password] )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_password').with_secret( true )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_virtual_host').with_value( params[:rabbit_virtual_host] )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('0')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_rate').with_value('<SERVICE DEFAULT>')
    end
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_host').with_value( params[:rabbit_host] ) }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_port').with_value( params[:rabbit_port] ) }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_hosts').with_ensure('absent') }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('<SERVICE DEFAULT>') }
    it { is_expected.to contain_heat_config('DEFAULT/rpc_response_timeout').with_value('<SERVICE DEFAULT>') }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>') }
  end

  shared_examples_for 'rabbit without HA support (without backward compatibility)' do
    it 'configures rabbit' do
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_userid').with_value( params[:rabbit_userid] )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_password').with_secret( true )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_password').with_value( params[:rabbit_password] )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_virtual_host').with_value( params[:rabbit_virtual_host] )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('0')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_rate').with_value('<SERVICE DEFAULT>')
    end
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_host').with_ensure('absent') }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_port').with_ensure('absent') }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_hosts').with_value( params[:rabbit_hosts].join(',') ) }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('<SERVICE DEFAULT>') }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/amqp_durable_queues').with_value('<SERVICE DEFAULT>') }
  end

  shared_examples_for 'rabbit with HA support' do
    it 'configures rabbit' do
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_userid').with_value( params[:rabbit_userid] )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_password').with_value( params[:rabbit_password] )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_password').with_secret( true )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_virtual_host').with_value( params[:rabbit_virtual_host] )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('0')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_rate').with_value('<SERVICE DEFAULT>')
    end
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_host').with_ensure('absent') }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_port').with_ensure('absent') }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_hosts').with_value( params[:rabbit_hosts].join(',') ) }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('true') }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/amqp_durable_queues').with_value(true) }
  end

  shared_examples_for 'single rabbit_host with ha queues' do
    let :params do
      req_params.merge({'rabbit_ha_queues' => true})
    end

    it 'should contain rabbit_ha_queues' do
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('true')
    end
  end

  shared_examples_for 'rabbit with heartbeat configured' do
    it 'configures rabbit' do
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_userid').with_value( params[:rabbit_userid] )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_password').with_value( params[:rabbit_password] )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_password').with_secret( true )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_virtual_host').with_value( params[:rabbit_virtual_host] )
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
    end
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('60') }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_rate').with_value('10') }
  end

  shared_examples_for 'with SSL enabled with kombu' do
    before do
      params.merge!(
        :rabbit_use_ssl     => true,
        :kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
        :kombu_ssl_certfile => '/path/to/ssl/cert/file',
        :kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
        :kombu_ssl_version  => 'TLSv1'
      )
    end

    it do
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('/path/to/ssl/ca/certs')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('/path/to/ssl/cert/file')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('/path/to/ssl/keyfile')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('TLSv1')
    end
  end

  shared_examples_for 'with SSL enabled without kombu' do
    before do
      params.merge!(
        :rabbit_use_ssl     => true
      )
    end

    it do
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('true')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples_for 'with SSL disabled' do
    before do
      params.merge!(
        :rabbit_use_ssl     => false,
      )
    end

    it do
      is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_use_ssl').with_value('false')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_ca_certs').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_certfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_keyfile').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_ssl_version').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples_for 'with SSL wrongly configured' do
    before do
      params.merge!(
        :rabbit_use_ssl     => false
      )
    end

    context 'without required parameters' do

      context 'with rabbit_use_ssl => false and kombu_ssl_ca_certs parameter' do
        before { params.merge!(:kombu_ssl_ca_certs => '/path/to/ssl/ca/certs')}
        it_raises 'a Puppet::Error', /The kombu_ssl_ca_certs parameter requires rabbit_use_ssl to be set to true/
      end

      context 'with rabbit_use_ssl => false and kombu_ssl_certfile parameter' do
        before { params.merge!(:kombu_ssl_certfile => '/path/to/ssl/cert/file')}
        it_raises 'a Puppet::Error', /The kombu_ssl_certfile parameter requires rabbit_use_ssl to be set to true/
      end

      context 'with rabbit_use_ssl => false and kombu_ssl_keyfile parameter' do
        before { params.merge!(:kombu_ssl_keyfile => '/path/to/ssl/keyfile')}
        it_raises 'a Puppet::Error', /The kombu_ssl_keyfile parameter requires rabbit_use_ssl to be set to true/
      end
      context 'with kombu_ssl_certfile set to default and custom kombu_ssl_keyfile parameter' do
        before { params.merge!(
          :rabbit_use_ssl    => true,
          :kombu_ssl_keyfile => '/path/to/ssl/keyfile',
        )}
        it_raises 'a Puppet::Error', /The kombu_ssl_certfile and kombu_ssl_keyfile parameters must be used together/
      end
      context 'with kombu_ssl_keyfile set to default and custom kombu_ssl_certfile parameter' do
        before { params.merge!(
          :rabbit_use_ssl    => true,
          :kombu_ssl_certfile => '/path/to/ssl/cert/file',
        )}
        it_raises 'a Puppet::Error', /The kombu_ssl_certfile and kombu_ssl_keyfile parameters must be used together/
      end
    end

  end

  shared_examples_for 'with ec2authtoken auth uri set' do
    before do
      params.merge!(
        :keystone_ec2_uri => 'http://1.2.3.4:35357/v2.0/ec2tokens'
      )
    end

    it do
      is_expected.to contain_heat_config('ec2authtoken/auth_uri').with_value('http://1.2.3.4:35357/v2.0/ec2tokens')
    end
  end

  shared_examples_for 'with region_name set' do
    before do
      params.merge!(
        :region_name => "East",
      )
    end

    it 'has region_name set when specified' do
      is_expected.to contain_heat_config('DEFAULT/region_name_for_services').with_value('East')
    end
  end

  shared_examples_for 'without region_name set' do
    it 'doesnt have region_name set by default' do
      is_expected.to contain_heat_config('DEFAULT/region_name_for_services').with_value('<SERVICE DEFAULT>')
    end
  end

  shared_examples_for "with default auth method" do
    it 'configures auth_uri, identity_uri, admin_tenant_name, admin_user, admin_password' do
      is_expected.to contain_heat_config('keystone_authtoken/auth_uri').with_value("http://127.0.0.1:5000/")
      is_expected.to contain_heat_config('keystone_authtoken/identity_uri').with_value("http://127.0.0.1:35357/")
      is_expected.to contain_heat_config('keystone_authtoken/admin_tenant_name').with_value("services")
      is_expected.to contain_heat_config('keystone_authtoken/admin_user').with_value("heat")
      is_expected.to contain_heat_config('keystone_authtoken/admin_password').with_secret( true )
    end
  end

  shared_examples_for "with auth_plugin" do
    before do
      params.merge!({
        :auth_plugin => 'password',
      })
    end
    it 'configures ' do
      is_expected.to contain_heat_config('keystone_authtoken/auth_plugin').with_value("password")
      is_expected.to contain_heat_config('keystone_authtoken/auth_url').with_value("http://127.0.0.1:35357/")
      is_expected.to contain_heat_config('keystone_authtoken/username').with_value("heat")
      is_expected.to contain_heat_config('keystone_authtoken/password').with_secret( true )
      is_expected.to contain_heat_config('keystone_authtoken/project_name').with_value("services")
      is_expected.to contain_heat_config('keystone_authtoken/user_domain_id').with_value('default')
      is_expected.to contain_heat_config('keystone_authtoken/project_domain_id').with_value('default')
    end
  end

  shared_examples_for "with custom keystone project_domain_id and user_domain_id" do
    before do
      params.merge!({
        :keystone_project_domain_id => 'domain1',
        :keystone_user_domain_id => 'domain1',
      })
    end
    it 'configures project_domain_id and user_domain_id' do
      is_expected.to contain_heat_config('trustee/project_domain_id').with_value("domain1");
      is_expected.to contain_heat_config('trustee/user_domain_id').with_value("domain1");
    end
  end

  shared_examples_for 'with instance_user set to a string' do
    before do
      params.merge!(
        :instance_user => "fred",
      )
    end

    it 'has instance_user set when specified' do
      is_expected.to contain_heat_config('DEFAULT/instance_user').with_value('fred')
    end
  end

  shared_examples_for 'with instance_user set to an empty string' do
    before do
      params.merge!(
        :instance_user => "",
      )
    end

    it 'has instance_user set to an empty string when specified' do
      is_expected.to contain_heat_config('DEFAULT/instance_user').with_value('')
    end
  end

  shared_examples_for 'without instance_user set' do
    it 'doesnt have instance_user set by default' do
      is_expected.to contain_heat_config('DEFAULT/instance_user').with_enure('absent')
    end
  end

  shared_examples_for "with enable_stack_adopt and enable_stack_abandon set" do
    before do
      params.merge!({
        :enable_stack_adopt   => true,
        :enable_stack_abandon => true,
      })
    end
    it 'sets enable_stack_adopt and enable_stack_abandon' do
      is_expected.to contain_heat_config('DEFAULT/enable_stack_adopt').with_value(true);
      is_expected.to contain_heat_config('DEFAULT/enable_stack_abandon').with_value(true);
    end
  end

  shared_examples_for 'with notification_driver set to a string' do
    before do
      params.merge!(
        :notification_driver => 'bar.foo.rpc_notifier',
      )
    end

    it 'has notification_driver set when specified' do
      is_expected.to contain_heat_config('DEFAULT/notification_driver').with_value('bar.foo.rpc_notifier')
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily => 'Debian',
      })
    end

    let :platform_params do
      { :common_package_name => 'heat-common' }
    end

    it_configures 'heat'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily => 'RedHat',
      })
    end

    let :platform_params do
      { :common_package_name => 'openstack-heat-common' }
    end

    it_configures 'heat'
  end
end
