require 'spec_helper'

describe 'heat::clients::zaqar' do
  shared_examples 'heat::clients::zaqar' do
    context 'with defaults' do
      it 'configures defaults' do
        is_expected.to contain_heat__clients__base('clients_zaqar').with(
          :endpoint_type => '<SERVICE DEFAULT>',
          :ca_file       => '<SERVICE DEFAULT>',
          :cert_file     => '<SERVICE DEFAULT>',
          :key_file      => '<SERVICE DEFAULT>',
          :insecure      => '<SERVICE DEFAULT>',
        )
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

      it 'configures client parameters' do
        is_expected.to contain_heat__clients__base('clients_zaqar').with(
          :endpoint_type => 'publicURL',
          :ca_file       => '/path/to/ca.cert',
          :cert_file     => '/path/to/certfile',
          :key_file      => '/path/to/key',
          :insecure      => false,
        )
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

      it_behaves_like 'heat::clients::zaqar'
    end
  end
end
