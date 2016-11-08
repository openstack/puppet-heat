require 'spec_helper'

describe 'heat::wsgi::apache' do


  let :params do
    {
      :port => 8000,
    }
  end

  shared_examples_for 'apache serving a service with mod_wsgi' do
    context 'valid title' do
      let (:title) { 'api' }
      it { is_expected.to contain_class('heat::deps') }
      it { is_expected.to contain_class('heat::params') }
      it { is_expected.to contain_class('apache') }
      it { is_expected.to contain_class('apache::mod::wsgi') }
      it { is_expected.to contain_class('apache::mod::ssl') }

      context 'with default parameters' do
        it { is_expected.to contain_openstacklib__wsgi__apache("heat_#{title}_wsgi").with(
          'bind_host'                   => nil,
          'bind_port'                   => '8000',
          'group'                       => 'heat',
          'user'                        => 'heat',
          'ssl'                         => 'true',
          'wsgi_daemon_process'         => "heat_#{title}",
          'wsgi_process_group'          => "heat_#{title}",
          'wsgi_script_dir'             => platform_params[:wsgi_script_dir],
          'wsgi_script_file'            => "heat_#{title}",
          'allow_encoded_slashes'       => 'on',
        )}
        it { is_expected.to contain_concat("#{platform_params[:httpd_ports_file]}") }
      end

      context 'with bind host' do
        let(:params) do
          { :bind_host => '1.1.1.1', :port => 9000 }
        end
        it { is_expected.to contain_openstacklib__wsgi__apache("heat_#{title}_wsgi").with(
          'bind_host' => '1.1.1.1',
          'bind_port' => 9000, )
        }
      end

      context 'with api options' do
        let (:title) { 'api' }
        it { is_expected.to contain_openstacklib__wsgi__apache("heat_#{title}_wsgi").with(
          'wsgi_daemon_process'         => "heat_#{title}",
          'wsgi_process_group'          => "heat_#{title}",
          'wsgi_script_dir'             => platform_params[:wsgi_script_dir],
          'wsgi_script_file'            => "heat_#{title}",
          'wsgi_script_source'          => platform_params[:script_source_api],
        )}
      end

      context 'with cfn options' do
        let (:title) { 'api_cfn' }
        it { is_expected.to contain_openstacklib__wsgi__apache("heat_#{title}_wsgi").with(
          'wsgi_daemon_process'         => "heat_#{title}",
          'wsgi_process_group'          => "heat_#{title}",
          'wsgi_script_dir'             => platform_params[:wsgi_script_dir],
          'wsgi_script_file'            => "heat_#{title}",
          'wsgi_script_source'          => platform_params[:script_source_cfn],
        )}
      end

      context 'with cloudwatch options' do
        let (:title) { 'api_cloudwatch' }
        it { is_expected.to contain_openstacklib__wsgi__apache("heat_#{title}_wsgi").with(
          'wsgi_daemon_process'         => "heat_#{title}",
          'wsgi_process_group'          => "heat_#{title}",
          'wsgi_script_dir'             => platform_params[:wsgi_script_dir],
          'wsgi_script_file'            => "heat_#{title}",
          'wsgi_script_source'          => platform_params[:script_source_cloudwatch],
        )}
      end

    end

    context 'invalid title' do
      let (:title) { 'someothertitle' }
      it { expect { is_expected.to raise_error(Puppet::Error) } }
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :httpd_service_name       => 'apache2',
            :httpd_ports_file         => '/etc/apache2/ports.conf',
            :wsgi_script_dir          => '/usr/lib/cgi-bin/heat',
            :script_source_api        => '/usr/bin/heat-wsgi-api',
            :script_source_cfn        => '/usr/bin/heat-wsgi-api-cfn',
            :script_source_cloudwatch => '/usr/bin/heat-wsgi-api-cloudwatch',
          }
        when 'RedHat'
          { :httpd_service_name       => 'httpd',
            :httpd_ports_file         => '/etc/httpd/conf/ports.conf',
            :wsgi_script_dir          => '/var/www/cgi-bin/heat',
            :script_source_api        => '/usr/bin/heat-wsgi-api',
            :script_source_cfn        => '/usr/bin/heat-wsgi-api-cfn',
            :script_source_cloudwatch => '/usr/bin/heat-wsgi-api-cloudwatch',
          }
        end
      end
      it_configures 'apache serving a service with mod_wsgi'
    end
  end

end
