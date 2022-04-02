require 'spec_helper'

describe 'heat::clients::base' do
  let (:title) do
    'clients_foo'
  end

  shared_examples 'heat::clients::base' do
    context 'with defaults' do
      it 'configures defaults' do
        is_expected.to contain_heat_config('clients_foo/endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('clients_foo/ca_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('clients_foo/cert_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('clients_foo/key_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_heat_config('clients_foo/insecure').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with parameters' do
      let :params do
        {
          :endpoint_type => 'publicURL',
          :ca_file       => '/path/to/ca.cert',
          :cert_file     => '/path/to/certfile',
          :key_file      => '/path/to/key',
          :insecure      => false,
        }
      end

      it 'configures defaults' do
        is_expected.to contain_heat_config('clients_foo/endpoint_type').with_value('publicURL')
        is_expected.to contain_heat_config('clients_foo/ca_file').with_value('/path/to/ca.cert')
        is_expected.to contain_heat_config('clients_foo/cert_file').with_value('/path/to/certfile')
        is_expected.to contain_heat_config('clients_foo/key_file').with_value('/path/to/key')
        is_expected.to contain_heat_config('clients_foo/insecure').with_value(false)
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'heat::clients::base'
    end
  end
end
