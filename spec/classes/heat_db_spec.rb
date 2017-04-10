require 'spec_helper'

describe 'heat::db' do

  shared_examples 'heat::db' do

    context 'with default parameters' do

      it { is_expected.to contain_class('heat::db::sync') }
      it { is_expected.to contain_oslo__db('heat_config').with(
        :db_max_retries => '<SERVICE DEFAULT>',
        :connection     => 'sqlite:////var/lib/heat/heat.sqlite',
        :idle_timeout   => '<SERVICE DEFAULT>',
        :min_pool_size  => '<SERVICE DEFAULT>',
        :max_pool_size  => '<SERVICE DEFAULT>',
        :max_retries    => '<SERVICE DEFAULT>',
        :retry_interval => '<SERVICE DEFAULT>',
      )}

    end

    context 'with specific parameters' do
      let :params do
        { :database_connection     => 'mysql+pymysql://heat:heat@localhost/heat',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_pool_size  => '12',
          :database_max_retries    => '11',
          :database_retry_interval => '11',
          :database_db_max_retries => '-1',
          :sync_db                 => false }
      end

      it { is_expected.not_to contain_class('heat::db::sync') }
      it { is_expected.to contain_oslo__db('heat_config').with(
        :db_max_retries => '-1',
        :connection     => 'mysql+pymysql://heat:heat@localhost/heat',
        :idle_timeout   => '3601',
        :min_pool_size  => '2',
        :max_pool_size  => '12',
        :max_retries    => '11',
        :retry_interval => '11',
      )}

    end

    context 'with MySQL-python library as backend package' do
      let :params do
        { :database_connection => 'mysql://heat:heat@localhost/heat' }
      end

      it { is_expected.to contain_oslo__db('heat_config').with(
        :connection => 'mysql://heat:heat@localhost/heat',
      )}
    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection => 'postgresql://heat:heat@localhost/heat', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection => 'redis://heat:heat@localhost/heat', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection => 'foo+pymysql://heat:heat@localhost/heat', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'heat::db'

      context 'using pymysql driver' do
        let :params do
          { :database_connection => 'mysql+pymysql://heat:heat@localhost/heat' }
        end

        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_package('db_backend_package').with({ :ensure => 'present', :name => 'python-pymysql' }) }
        when 'RedHat'
          it { is_expected.not_to contain_package('db_backend_package') }
        end
      end

    end
  end

end
