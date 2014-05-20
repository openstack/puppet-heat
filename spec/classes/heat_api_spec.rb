require 'spec_helper'

describe 'heat::api' do

  let :params do
    {
      :bind_host => '127.0.0.1',
      :bind_port => '1234',
      :workers   => '0'
    }
  end

  let :facts do
    { :osfamily => 'Debian' }
  end

  context 'config params' do

    it { should contain_class('heat') }
    it { should contain_class('heat::params') }

    it { should contain_heat_config('heat_api/bind_host').with_value( params[:bind_host] ) }
    it { should contain_heat_config('heat_api/bind_port').with_value( params[:bind_port] ) }
    it { should contain_heat_config('heat_api/workers').with_value( params[:workers] ) }

  end

  context 'with SSL socket options set' do
    let :params do
      {
        :use_ssl   => true,
        :cert_file => '/path/to/cert',
        :key_file  => '/path/to/key'
      }
    end

    it { should contain_heat_config('heat_api/cert_file').with_value('/path/to/cert') }
    it { should contain_heat_config('heat_api/key_file').with_value('/path/to/key') }
  end

  context 'with SSL socket options set with wrong parameters' do
    let :params do
      {
        :use_ssl   => true,
        :key_file  => '/path/to/key'
      }
    end

    it_raises 'a Puppet::Error', /The cert_file parameter is required when use_ssl is set to true/
  end

  context 'with SSL socket options set to false' do
    let :params do
      {
        :use_ssl   => false,
        :cert_file => false,
        :key_file  => false
      }
    end

    it { should contain_heat_config('heat_api/cert_file').with_ensure('absent') }
    it { should contain_heat_config('heat_api/key_file').with_ensure('absent') }
  end

end
