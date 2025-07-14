require 'spec_helper'

describe 'heat::db::mysql' do

  let :params do
    { :password     => 'heatpass',
      :dbname       => 'heat',
      :user         => 'heat',
      :host         => 'localhost',
      :charset      => 'utf8',
      :collate      => 'utf8_general_ci',
    }
  end

  shared_examples_for 'heat mysql database' do
    it { is_expected.to contain_class('heat::deps') }

    context 'when omitting the required parameter password' do
      before { params.delete(:password) }
      it { is_expected.to raise_error(Puppet::Error) }
    end

    it 'creates a mysql database' do
      is_expected.to contain_openstacklib__db__mysql( params[:dbname] ).with(
        :user          => params[:user],
        :password      => params[:password],
        :host          => params[:host],
        :charset       => params[:charset],
        :collate       => params[:collate],
      )
    end
  end

  describe "overriding allowed_hosts param to array" do
    let :params do
      {
        :password       => 'heatpass',
        :allowed_hosts  => ['localhost','%']
      }
    end

  end

  describe "overriding allowed_hosts param to string" do
    let :params do
      {
        :password       => 'heatpass2',
        :allowed_hosts  => '192.168.1.1'
      }
    end

  end

  describe "overriding allowed_hosts param equals to host param " do
    let :params do
      {
        :password       => 'heatpass2',
        :allowed_hosts  => 'localhost'
      }
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_behaves_like 'heat mysql database'
    end
  end

end
