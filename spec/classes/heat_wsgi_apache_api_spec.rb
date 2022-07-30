require 'spec_helper'

describe 'heat::wsgi::apache_api' do

  shared_examples_for 'heat::wsgi::apache_api' do
    context 'default parameters' do
      it { is_expected.to contain_class('heat::wsgi::apache_api') }
      it { is_expected.to contain_heat__wsgi__apache('api').with(
        :port                        => 8004,
        :servername                  => facts[:fqdn],
        :bind_host                   => nil,
        :path                        => '/',
        :ssl                         => false,
        :workers                     => facts[:os_workers],
        :ssl_cert                    => nil,
        :ssl_key                     => nil,
        :ssl_chain                   => nil,
        :ssl_ca                      => nil,
        :ssl_crl_path                => nil,
        :ssl_certs_dir               => nil,
        :wsgi_process_display_name   => nil,
        :vhost_custom_fragment       => nil,
        :threads                     => 1,
        :priority                    => 10,
        :headers                     => nil,
        :request_headers             => nil,
        :custom_wsgi_process_options => {},
        :access_log_file             => nil,
        :access_log_format           => nil,
      )}
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'heat::wsgi::apache_api'
    end
  end

end
