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

    describe 'overriding extra_params' do
      let :params do
        {
          :extra_params => '--config-file /etc/heat/heat01.conf',
        }
      end

      it {
        is_expected.to contain_exec('heat-dbsync').with(
          :command     => 'heat-manage --config-file /etc/heat/heat01.conf db_sync',
          :path        => '/usr/bin',
          :user        => 'heat',
          :refreshonly => 'true',
          :logoutput   => 'on_failure'
        )
        }
      end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :processorcount => 8,
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_configures 'heat-dbsync'
    end
  end

end
