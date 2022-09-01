require 'spec_helper_acceptance'

describe 'basic heat' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include openstack_integration
      include openstack_integration::repos
      include openstack_integration::apache
      include openstack_integration::rabbitmq
      include openstack_integration::mysql
      include openstack_integration::memcached
      include openstack_integration::keystone
      include openstack_integration::heat
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(8000) do
      it { is_expected.to be_listening }
    end

    describe port(8004) do
      it { is_expected.to be_listening }
    end

    describe cron do
      it { is_expected.to have_entry('1 0 * * * heat-manage purge_deleted -g days 1 >>/var/log/heat/heat-purge_deleted.log 2>&1').with_user('heat') }
    end
  end
end
