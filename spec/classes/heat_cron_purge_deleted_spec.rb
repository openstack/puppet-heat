require 'spec_helper'

describe 'heat::cron::purge_deleted' do

  let :facts do
    @default_facts.merge({ :osfamily => 'Debian' })
  end

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
     include ::heat"
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
        :weekday     => params[:weekday]
      )
      is_expected.to contain_package('heat-common').that_comes_before('Cron[heat-manage purge_deleted]')
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
        :weekday     => params[:weekday]
      )
      is_expected.to contain_package('heat-common').that_comes_before('Cron[heat-manage purge_deleted]')
    end
  end

  describe 'when disabling cron job' do
    before :each do
      params.merge!(
        :ensure => 'absent'
      )
    end

    it 'configures a cron with delay' do
      is_expected.to contain_cron('heat-manage purge_deleted').with(
        :ensure      => params[:ensure],
        :command     => "heat-manage purge_deleted -g days 1 >>#{params[:destination]} 2>&1",
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'heat',
        :minute      => params[:minute],
        :hour        => params[:hour],
        :monthday    => params[:monthday],
        :month       => params[:month],
        :weekday     => params[:weekday]
      )
      is_expected.to contain_package('heat-common').that_comes_before('Cron[heat-manage purge_deleted]')
    end
  end

  describe 'when setting a wrong age_type' do
    before :each do
      params.merge!(
        :age_type => 'foobar'
      )
    end

    it_raises 'a Puppet::Error', /age_type possible values are only days, hours, minutes, or seconds./
  end
end
