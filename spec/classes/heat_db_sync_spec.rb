require 'spec_helper'

describe 'heat::db::sync' do

  shared_examples_for 'heat-dbsync' do

    it { is_expected.to contain_class('heat::deps') }

    it 'runs heat-manage db_sync' do
      is_expected.to contain_exec('heat-dbsync').with(
        :command     => 'heat-manage  db_sync',
        :path        => '/usr/bin',
        :user        => 'heat',
        :refreshonly => 'true',
        :try_sleep   => 5,
        :tries       => 10,
        :timeout     => 300,
        :logoutput   => 'on_failure',
        :subscribe   => ['Anchor[heat::install::end]',
                         'Anchor[heat::config::end]',
                         'Anchor[heat::dbsync::begin]'],
        :notify      => 'Anchor[heat::dbsync::end]',
        :tag         => 'openstack-db',
      )
    end

    describe 'overriding params' do
      let :params do
        {
          :extra_params    => '--config-file /etc/heat/heat01.conf',
          :db_sync_timeout => 750,
        }
      end

      it {
        is_expected.to contain_exec('heat-dbsync').with(
          :command     => 'heat-manage --config-file /etc/heat/heat01.conf db_sync',
          :path        => '/usr/bin',
          :user        => 'heat',
          :refreshonly => 'true',
          :try_sleep   => 5,
          :tries       => 10,
          :timeout     => 750,
          :logoutput   => 'on_failure',
          :subscribe   => ['Anchor[heat::install::end]',
                           'Anchor[heat::config::end]',
                           'Anchor[heat::dbsync::begin]'],
          :notify      => 'Anchor[heat::dbsync::end]',
          :tag         => 'openstack-db',
        )
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

      it_behaves_like 'heat-dbsync'
    end
  end

end
