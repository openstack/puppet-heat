require 'spec_helper'

describe 'heat::wsgi::apache_api_cfn' do

  shared_examples_for 'heat::wsgi::apache_api_cfn' do
    context 'default parameters' do
      it { is_expected.to contain_class('heat::wsgi::apache_api_cfn') }
      it { is_expected.to contain_heat__wsgi__apache('api_cfn').with(
        :port          => 8000,
        :servername    => facts[:fqdn],
        :bind_host     => nil,
        :path          => '/',
        :ssl           => true,
        :workers       => 1,
        :ssl_cert      => nil,
        :ssl_key       => nil,
        :ssl_chain     => nil,
        :ssl_ca        => nil,
        :ssl_crl_path  => nil,
        :ssl_certs_dir => nil,
        :threads       => facts[:os_workers],
        :priority      => 10, )
      }
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'heat::wsgi::apache_api_cfn'
    end
  end

end
