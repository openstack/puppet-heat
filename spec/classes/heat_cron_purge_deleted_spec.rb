require 'spec_helper'

describe 'heat::cron::purge_deleted' do
  shared_examples_for 'heat::cron::purge_deleted' do

    let :params do
      { :ensure      => 'present',
        :minute      => 1,
        :hour        => 0,
        :monthday    => '*',
        :month       => '*',
        :weekday     => '*',
        :maxdelay    => 0,
        :user        => 'heat',
        :age         => 1,
        :age_type    => 'days',
        :destination => '/var/log/heat/heat-purge_deleted.log' }
    end

    let :pre_condition do
      "class { 'heat::keystone::authtoken':
         password => 'password',
       }
       include heat"
    end

    describe 'with default parameters' do
      it 'configures a cron' do
        is_expected.to contain_cron('heat-manage purge_deleted').with(
          :ensure      => params[:ensure],
          :command     => "heat-manage purge_deleted -g days 1 >>#{params[:destination]} 2>&1",
          :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
          :user        => 'heat',
          :minute      => params[:minute],
          :hour        => params[:hour],
          :monthday    => params[:monthday],
          :month       => params[:month],
          :weekday     => params[:weekday],
          :require     => 'Anchor[heat::dbsync::end]'
        )
      end
    end

    describe 'when specifying a maxdelay param' do
      before :each do
        params.merge!(
          :maxdelay => 600
        )
      end

      it 'configures a cron with delay' do
        is_expected.to contain_cron('heat-manage purge_deleted').with(
          :ensure      => params[:ensure],
          :command     => "sleep `expr ${RANDOM} \\% #{params[:maxdelay]}`; heat-manage purge_deleted -g days 1 >>#{params[:destination]} 2>&1",
          :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
          :user        => 'heat',
          :minute      => params[:minute],
          :hour        => params[:hour],
          :monthday    => params[:monthday],
          :month       => params[:month],
          :weekday     => params[:weekday],
          :require     => 'Anchor[heat::dbsync::end]'
        )
      end
    end

    describe 'when batch_size is set' do
      before :each do
        params.merge!(
          :batch_size => 100
        )
      end

      it 'disables the cron job' do
        is_expected.to contain_cron('heat-manage purge_deleted').with(
          :ensure      => params[:ensure],
          :command     => "heat-manage purge_deleted -g days 1 -b #{params[:batch_size]} >>#{params[:destination]} 2>&1",
          :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
          :user        => 'heat',
          :minute      => params[:minute],
          :hour        => params[:hour],
          :monthday    => params[:monthday],
          :month       => params[:month],
          :weekday     => params[:weekday],
          :require     => 'Anchor[heat::dbsync::end]'
        )
      end
    end

    describe 'when disabling cron job' do
      before :each do
        params.merge!(
          :ensure => 'absent'
        )
      end

      it 'disables the cron job' do
        is_expected.to contain_cron('heat-manage purge_deleted').with(
          :ensure      => params[:ensure],
          :command     => "heat-manage purge_deleted -g days 1 >>#{params[:destination]} 2>&1",
          :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
          :user        => 'heat',
          :minute      => params[:minute],
          :hour        => params[:hour],
          :monthday    => params[:monthday],
          :month       => params[:month],
          :weekday     => params[:weekday],
          :require     => 'Anchor[heat::dbsync::end]'
        )
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'heat::cron::purge_deleted'
    end
  end

end
