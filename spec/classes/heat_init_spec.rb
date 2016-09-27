require 'spec_helper'

describe 'heat' do

  let :params do
    {
      :package_ensure        => 'present',
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
      :purge_config          => false,
      :yaql_limit_iterators  => 400,
      :yaql_memory_quota     => 20000,
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
    it_configures 'with enable_stack_adopt and enable_stack_abandon set'
    it_configures 'with notification_driver set to a string'

    context 'with amqp rpc_backend value' do
      it_configures 'amqp support'
    end
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

    it 'passes purge to resource' do
      is_expected.to contain_resources('heat_config').with({
        :purge => false
      })
    end

    it 'has db_sync enabled' do
      is_expected.to contain_class('heat::db::sync')
    end

    it 'configures host' do
      is_expected.to contain_heat_config('DEFAULT/host').with_value('<SERVICE DEFAULT>')
    end

    it 'configures max_template_size' do
      is_expected.to contain_heat_config('DEFAULT/max_template_size').with_value('<SERVICE DEFAULT>')
    end

    it 'configures max_json_body_size' do
      is_expected.to contain_heat_config('DEFAULT/max_json_body_size').with_value('<SERVICE DEFAULT>')
    end

    it 'configures project_domain_*' do
      is_expected.to contain_heat_config('trustee/project_domain_id').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('trustee/project_domain_name').with_value( 'Default' )
    end

    it 'configures user_domain_*' do
      is_expected.to contain_heat_config('trustee/user_domain_id').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('trustee/user_domain_name').with_value( 'Default' )
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

    it 'configures yaql_limit_iterators' do
      is_expected.to contain_heat_config('yaql/limit_iterators').with_value( params[:yaql_limit_iterators] )
    end

    it 'configures yaql_memory_quota' do
      is_expected.to contain_heat_config('yaql/memory_quota').with_value( params[:yaql_memory_quota] )
    end

    it { is_expected.to contain_heat_config('paste_deploy/flavor').with_value('keystone') }

    it 'configures notification_driver' do
        is_expected.to contain_heat_config('oslo_messaging_notifications/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('oslo_messaging_notifications/driver').with_value('<SERVICE DEFAULT>')
    end

    it 'sets default value for http_proxy_to_wsgi middleware' do
      is_expected.to contain_heat_config('oslo_middleware/enable_proxy_headers_parsing').with_value('<SERVICE DEFAULT>')
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
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_failover_strategy').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_compression').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('0')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_rate').with_value('<SERVICE DEFAULT>')
    end
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_host').with_value( params[:rabbit_host] ) }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_port').with_value( params[:rabbit_port] ) }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_hosts').with_value('<SERVICE DEFAULT>') }
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
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_failover_strategy').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_compression').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('0')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_rate').with_value('<SERVICE DEFAULT>')
    end
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_host').with_value('<SERVICE DEFAULT>') }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_port').with_value('<SERVICE DEFAULT>') }
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
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_failover_strategy').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_compression').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('0')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/heartbeat_rate').with_value('<SERVICE DEFAULT>')
    end
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_host').with_value('<SERVICE DEFAULT>') }
    it { is_expected.to contain_heat_config('oslo_messaging_rabbit/rabbit_port').with_value('<SERVICE DEFAULT>') }
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
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_failover_strategy').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_heat_config('oslo_messaging_rabbit/kombu_compression').with_value('<SERVICE DEFAULT>')
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
      is_expected.to contain_heat_config('keystone_authtoken/auth_url').with_value("http://127.0.0.1:35357/")
      is_expected.to contain_heat_config('keystone_authtoken/project_name').with_value("services")
      is_expected.to contain_heat_config('keystone_authtoken/username').with_value("heat")
      is_expected.to contain_heat_config('keystone_authtoken/password').with_secret( true )
    end
  end

  shared_examples_for "with custom keystone project_domain_* and user_domain_*" do
    before do
      params.merge!({
        :keystone_project_domain_id   => 'domain1',
        :keystone_user_domain_id      => 'domain1',
        :keystone_project_domain_name => 'domain1',
        :keystone_user_domain_name    => 'domain1',
      })
    end
    it 'configures project_domain_* and user_domain_*' do
      is_expected.to contain_heat_config('trustee/project_domain_name').with_value("domain1");
      is_expected.to contain_heat_config('trustee/user_domain_name').with_value("domain1");
      is_expected.to contain_heat_config('trustee/project_domain_id').with_value("domain1");
      is_expected.to contain_heat_config('trustee/user_domain_id').with_value("domain1");
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
        :notification_transport_url => 'rabbit://rabbit_user:password@localhost:5673',
        :notification_driver        => 'bar.foo.rpc_notifier',
      )
    end

    it 'has notification_driver set when specified' do
      is_expected.to contain_heat_config('oslo_messaging_notifications/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
      is_expected.to contain_heat_config('oslo_messaging_notifications/driver').with_value('bar.foo.rpc_notifier')
    end
  end

  shared_examples_for 'amqp support' do
    context 'with default parameters' do
      before { params.merge!( :rpc_backend => 'amqp' ) }

      it { is_expected.to contain_heat_config('DEFAULT/rpc_backend').with_value('amqp') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/server_request_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/broadcast_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/group_request_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/container_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/idle_timeout').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/trace').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/ssl_ca_file').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/ssl_cert_file').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/ssl_key_file').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/ssl_key_password').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/allow_insecure_clients').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/username').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/password').with_value('<SERVICE DEFAULT>') }
    end

    context 'with overriden amqp parameters' do
      before { params.merge!(
        :rpc_backend        => 'amqp',
        :amqp_idle_timeout  => '60',
        :amqp_trace         => true,
        :amqp_ssl_ca_file   => '/path/to/ca.cert',
        :amqp_ssl_cert_file => '/path/to/certfile',
        :amqp_ssl_key_file  => '/path/to/key',
        :amqp_username      => 'amqp_user',
        :amqp_password      => 'password',
      ) }

      it { is_expected.to contain_heat_config('DEFAULT/rpc_backend').with_value('amqp') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/server_request_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/broadcast_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/group_request_prefix').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/container_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/idle_timeout').with_value('60') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/trace').with_value('true') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/ssl_ca_file').with_value('/path/to/ca.cert') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/ssl_cert_file').with_value('/path/to/certfile') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/ssl_key_file').with_value('/path/to/key') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/allow_insecure_clients').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/username').with_value('amqp_user') }
      it { is_expected.to contain_heat_config('oslo_messaging_amqp/password').with_value('password') }
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
