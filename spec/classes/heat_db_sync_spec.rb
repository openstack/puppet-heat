require 'spec_helper'

describe 'heat::db::sync' do

  shared_examples_for 'heat-dbsync' do

    it 'runs heat-manage db_sync' do
      is_expected.to contain_exec('heat-dbsync').with(
        :command     => 'heat-manage --config-file /etc/heat/heat.conf db_sync',
        :path        => '/usr/bin',
        :user        => 'heat',
        :refreshonly => 'true',
        :logoutput   => 'on_failure'
      )
    end

  end

  context 'on a RedHat osfamily' do
    let :facts do
      {
        :osfamily                 => 'RedHat',
        :operatingsystemrelease   => '7.0',
        :concat_basedir => '/var/lib/puppet/concat'
      }
    end

    it_configures 'heat-dbsync'
  end

  context 'on a Debian osfamily' do
    let :facts do
      {
        :operatingsystemrelease => '7.8',
        :operatingsystem        => 'Debian',
        :osfamily               => 'Debian',
        :concat_basedir => '/var/lib/puppet/concat'
      }
    end

    it_configures 'heat-dbsync'
  end

end
