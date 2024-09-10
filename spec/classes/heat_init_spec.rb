require 'spec_helper'

describe 'heat' do
  let :pre_condition do
    "class { 'heat::keystone::authtoken':
       password => 'secretpassword',
     }"
  end

  let :params do
    {
      :package_ensure       => 'present',
      :flavor               => 'keystone',
      :purge_config         => false,
      :yaql_limit_iterators => 400,
      :yaql_memory_quota    => 20000,
    }
  end

  shared_examples_for 'heat' do

    context 'with a normal setup' do
      it_configures 'a heat base installation'
      it_configures 'configures default rabbitmq parameters'
    end

    context 'with HA support' do
      it_configures 'configures rabbit with HA and durable'
    end

    context 'with rabbit heartbeat configured' do
      before { params.merge!(
        :rabbit_heartbeat_timeout_threshold => '60',
        :rabbit_heartbeat_rate => '10', 
        :rabbit_heartbeat_in_pthread => true ) }
      it_configures 'a heat base installation'
      it_configures 'rabbit with heartbeat configured'
    end

    it_configures 'with SSL enabled with kombu'
    it_configures 'with SSL enabled without kombu'
    it_configures 'with SSL disabled'
    it_configures 'with region_name set'
    it_configures 'without region_name set'
    it_configures 'with enable_stack_adopt and enable_stack_abandon set'
    it_configures 'with overridden messaging default parameters'
    it_configures 'with notification_driver set to a string'
  end

  shared_examples_for 'a heat base installation' do

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

    it 'configures default messaging default parameters' do
      is_expected.to contain_oslo__messaging__default('heat_config').with(
        :transport_url             => '<SERVICE DEFAULT>',
        :rpc_response_timeout      => '<SERVICE DEFAULT>',
        :control_exchange          => '<SERVICE DEFAULT>',
        :executor_thread_pool_size => '<SERVICE DEFAULT>',
      )
    end

    it 'configures max_template_size' do
      is_expected.to contain_heat_config('DEFAULT/max_template_size').with_value('<SERVICE DEFAULT>')
    end

    it 'configures max_json_body_size' do
      is_expected.to contain_heat_config('DEFAULT/max_json_body_size').with_value('<SERVICE DEFAULT>')
    end

    it 'configures template_fetch_timeout' do
      is_expected.to contain_heat_config('DEFAULT/template_fetch_timeout').with_value('<SERVICE DEFAULT>')
    end

    it 'configures keystone_ec2_uri' do
      is_expected.to contain_heat_config('ec2authtoken/auth_uri').with_value( '<SERVICE DEFAULT>' )
    end

    it 'configures yaql_limit_iterators' do
      is_expected.to contain_heat_config('yaql/limit_iterators').with_value( params[:yaql_limit_iterators] )
    end

    it 'configures yaql_memory_quota' do
      is_expected.to contain_heat_config('yaql/memory_quota').with_value( params[:yaql_memory_quota] )
    end

    it { is_expected.to contain_heat_config('paste_deploy/flavor').with_value('keystone') }

    it 'configures notification_driver' do
      is_expected.to contain_oslo__messaging__notifications('heat_config').with(
        :driver        => '<SERVICE DEFAULT>',
        :transport_url => '<SERVICE DEFAULT>',
        :topics        => '<SERVICE DEFAULT>'
      )
    end

    it 'sets default value for http_proxy_to_wsgi middleware' do
      is_expected.to contain_oslo__middleware('heat_config').with(
        :enable_proxy_headers_parsing => '<SERVICE DEFAULT>',
        :max_request_body_size        => '<SERVICE DEFAULT>',
      )
    end
  end

  shared_examples_for 'configures default rabbitmq parameters' do
    it 'configures rabbit' do
      is_expected.to contain_oslo__messaging__rabbit('heat_config').with(
        :kombu_ssl_version               => '<SERVICE DEFAULT>',
        :kombu_ssl_keyfile               => '<SERVICE DEFAULT>',
        :kombu_ssl_certfile              => '<SERVICE DEFAULT>',
        :kombu_ssl_ca_certs              => '<SERVICE DEFAULT>',
        :kombu_reconnect_delay           => '<SERVICE DEFAULT>',
        :kombu_failover_strategy         => '<SERVICE DEFAULT>',
        :kombu_compression               => '<SERVICE DEFAULT>',
        :heartbeat_timeout_threshold     => '<SERVICE DEFAULT>',
        :heartbeat_rate                  => '<SERVICE DEFAULT>',
        :heartbeat_in_pthread            => '<SERVICE DEFAULT>',
        :rabbit_use_ssl                  => '<SERVICE DEFAULT>',
        :amqp_durable_queues             => '<SERVICE DEFAULT>',
        :rabbit_ha_queues                => '<SERVICE DEFAULT>',
        :rabbit_quorum_queue             => '<SERVICE DEFAULT>',
        :rabbit_transient_quorum_queue   => '<SERVICE DEFAULT>',
        :rabbit_quorum_delivery_limit    => '<SERVICE DEFAULT>',
        :rabbit_quorum_max_memory_length => '<SERVICE DEFAULT>',
        :rabbit_quorum_max_memory_bytes  => '<SERVICE DEFAULT>',
      )
    end
  end

  shared_examples_for 'configures rabbit with HA and durable' do
    before do
      params.merge!( :rabbit_ha_queues    => true,
                     :amqp_durable_queues => true )
    end

    it 'configures rabbit' do
      is_expected.to contain_oslo__messaging__rabbit('heat_config').with(
        :kombu_ssl_version               => '<SERVICE DEFAULT>',
        :kombu_ssl_keyfile               => '<SERVICE DEFAULT>',
        :kombu_ssl_certfile              => '<SERVICE DEFAULT>',
        :kombu_ssl_ca_certs              => '<SERVICE DEFAULT>',
        :kombu_reconnect_delay           => '<SERVICE DEFAULT>',
        :kombu_failover_strategy         => '<SERVICE DEFAULT>',
        :kombu_compression               => '<SERVICE DEFAULT>',
        :heartbeat_timeout_threshold     => '<SERVICE DEFAULT>',
        :heartbeat_rate                  => '<SERVICE DEFAULT>',
        :heartbeat_in_pthread            => '<SERVICE DEFAULT>',
        :rabbit_use_ssl                  => '<SERVICE DEFAULT>',
        :amqp_durable_queues             => true,
        :rabbit_ha_queues                => true,
        :rabbit_quorum_queue             => '<SERVICE DEFAULT>',
        :rabbit_transient_quorum_queue   => '<SERVICE DEFAULT>',
        :rabbit_quorum_delivery_limit    => '<SERVICE DEFAULT>',
        :rabbit_quorum_max_memory_length => '<SERVICE DEFAULT>',
        :rabbit_quorum_max_memory_bytes  => '<SERVICE DEFAULT>',
      )
    end
  end

  shared_examples_for 'rabbit with heartbeat configured' do
    it 'configures rabbit' do
      is_expected.to contain_oslo__messaging__rabbit('heat_config').with(
        :kombu_ssl_version           => '<SERVICE DEFAULT>',
        :kombu_ssl_keyfile           => '<SERVICE DEFAULT>',
        :kombu_ssl_certfile          => '<SERVICE DEFAULT>',
        :kombu_ssl_ca_certs          => '<SERVICE DEFAULT>',
        :kombu_reconnect_delay       => '<SERVICE DEFAULT>',
        :kombu_failover_strategy     => '<SERVICE DEFAULT>',
        :kombu_compression           => '<SERVICE DEFAULT>',
        :heartbeat_timeout_threshold => '60',
        :heartbeat_rate              => '10',
        :heartbeat_in_pthread        => true,
        :rabbit_use_ssl              => '<SERVICE DEFAULT>',
        :amqp_durable_queues         => '<SERVICE DEFAULT>',
        :rabbit_ha_queues            => '<SERVICE DEFAULT>',
      )
    end
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

    it { is_expected.to contain_oslo__messaging__rabbit('heat_config').with(
      :kombu_ssl_version  => 'TLSv1',
      :kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
      :kombu_ssl_certfile => '/path/to/ssl/cert/file',
      :kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
      :rabbit_use_ssl     => true,
    )}
  end

  shared_examples_for 'with SSL enabled without kombu' do
    before do
      params.merge!(
        :rabbit_use_ssl     => true
      )
    end

    it { is_expected.to contain_oslo__messaging__rabbit('heat_config').with(
      :rabbit_use_ssl     => true,
    )}
  end

  shared_examples_for 'with SSL disabled' do
    before do
      params.merge!(
        :rabbit_use_ssl     => false,
      )
    end

    it { is_expected.to contain_oslo__messaging__rabbit('heat_config').with(
      :rabbit_use_ssl     => false,
    )}
  end

  shared_examples_for 'with ec2authtoken auth uri set' do
    before do
      params.merge!(
        :keystone_ec2_uri => 'http://1.2.3.4:5000/v3/ec2tokens'
      )
    end

    it do
      is_expected.to contain_heat_config('ec2authtoken/auth_uri').with_value('http://1.2.3.4:5000/v3/ec2tokens')
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

  shared_examples_for 'with overridden messaging default parameters' do
    before do
      params.merge!(
        :default_transport_url     => 'rabbit://rabbit_user:password@localhost:5673',
        :rpc_response_timeout      => 120,
        :control_exchange          => 'heat',
        :executor_thread_pool_size => 64,
      )
    end

    it 'configures messaging default parameters' do
      is_expected.to contain_oslo__messaging__default('heat_config').with(
        :transport_url             => 'rabbit://rabbit_user:password@localhost:5673',
        :rpc_response_timeout      => 120,
        :control_exchange          => 'heat',
        :executor_thread_pool_size => 64,
      )
    end
  end

  shared_examples_for 'with notification_driver set to a string' do
    before do
      params.merge!(
        :notification_transport_url => 'rabbit://rabbit_user:password@localhost:5673',
        :notification_driver        => 'messagingv2',
        :notification_topics        => 'notifications',
      )
    end

    it 'has notification_driver set when specified' do
      is_expected.to contain_oslo__messaging__notifications('heat_config').with(
        :driver        => 'messagingv2',
        :transport_url => 'rabbit://rabbit_user:password@localhost:5673',
        :topics        => 'notifications'
      )
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
          { :common_package_name => 'heat-common' }
        when 'RedHat'
          { :common_package_name => 'openstack-heat-common' }
        end
      end

      it_behaves_like 'heat'
    end
  end

end
