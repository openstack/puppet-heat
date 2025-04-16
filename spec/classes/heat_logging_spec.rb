require 'spec_helper'

describe 'heat::logging' do

  let :params do
    {
    }
  end

  let :log_params do
    {
      :logging_context_format_string => '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s',
      :logging_default_format_string => '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s',
      :logging_debug_format_suffix   => '%(funcName)s %(pathname)s:%(lineno)d',
      :logging_exception_prefix      => '%(asctime)s.%(msecs)03d %(process)d TRACE %(name)s %(instance)s',
      :log_config_append             => '/etc/heat/logging.conf',
      :publish_errors                => true,
      :default_log_levels => {
        'amqp' => 'WARN', 'amqplib' => 'WARN', 'boto' => 'WARN',
        'sqlalchemy' => 'WARN', 'suds' => 'INFO', 'iso8601' => 'WARN',
        'requests.packages.urllib3.connectionpool' => 'WARN' },
     :fatal_deprecations             => true,
     :instance_format                => '[instance: %(uuid)s] ',
     :instance_uuid_format           => '[instance: %(uuid)s] ',
     :log_date_format                => '%Y-%m-%d %H:%M:%S',
     :use_syslog                     => true,
     :use_json                       => true,
     :use_journal                    => true,
     :use_stderr                     => false,
     :log_facility                   => 'LOG_FOO',
     :log_dir                        => '/var/log',
     :log_file                       => '/var/log/heat/heat.log',
     :debug                          => true,
    }
  end

  shared_examples_for 'heat-logging' do

    context 'with basic logging options and default settings' do
      it_configures  'basic default logging settings'
    end

    context 'with basic logging options and non-default settings' do
      before { params.merge!( log_params ) }
      it_configures 'basic non-default logging settings'
    end

    context 'with extended logging options' do
      before { params.merge!( log_params ) }
      it_configures 'logging params set'
    end

    context 'without extended logging options' do
      it_configures 'logging params unset'
    end

  end

  shared_examples 'basic default logging settings' do
    it 'configures heat logging settings with default values' do
      is_expected.to contain_oslo__log('heat_config').with(
        :use_syslog     => '<SERVICE DEFAULT>',
        :use_json       => '<SERVICE DEFAULT>',
        :use_journal    => '<SERVICE DEFAULT>',
        :use_stderr     => '<SERVICE DEFAULT>',
        :log_dir        => '/var/log/heat',
        :log_file       => '<SERVICE DEFAULT>',
        :debug          => '<SERVICE DEFAULT>',
      )
    end
  end

  shared_examples 'basic non-default logging settings' do
    it 'configures heat logging settings with non-default values' do
      is_expected.to contain_oslo__log('heat_config').with(
        :use_syslog          => true,
        :use_json            => true,
        :use_journal         => true,
        :use_stderr          => false,
        :syslog_log_facility => 'LOG_FOO',
        :log_dir             => '/var/log',
        :log_file            => '/var/log/heat/heat.log',
        :debug               => true,
      )
    end
  end

  shared_examples_for 'logging params set' do
    it 'enables logging params' do
      is_expected.to contain_oslo__log('heat_config').with(
        :logging_context_format_string =>
          '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s',
        :logging_default_format_string => '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s',
        :logging_debug_format_suffix   => '%(funcName)s %(pathname)s:%(lineno)d',
        :logging_exception_prefix      => '%(asctime)s.%(msecs)03d %(process)d TRACE %(name)s %(instance)s',
        :log_config_append             => '/etc/heat/logging.conf',
        :publish_errors                => true,
        :default_log_levels            => {
          'amqp' => 'WARN', 'amqplib' => 'WARN', 'boto' => 'WARN',
          'sqlalchemy' => 'WARN', 'suds' => 'INFO', 'iso8601' => 'WARN',
          'requests.packages.urllib3.connectionpool' => 'WARN' },
       :fatal_deprecations             => true,
       :instance_format                => '[instance: %(uuid)s] ',
       :instance_uuid_format           => '[instance: %(uuid)s] ',
       :log_date_format                => '%Y-%m-%d %H:%M:%S',
      )
    end
  end

  shared_examples_for 'logging params unset' do
   [ :logging_context_format_string, :logging_default_format_string,
     :logging_debug_format_suffix, :logging_exception_prefix,
     :log_config_append, :publish_errors,
     :default_log_levels, :fatal_deprecations,
     :instance_format, :instance_uuid_format,
     :log_date_format, ].each { |param|
        it { is_expected.to contain_oslo__log('heat_config').with("#{param}" => '<SERVICE DEFAULT>') }
      }
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'heat-logging'
    end
  end

end
