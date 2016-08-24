require 'spec_helper_acceptance'

describe 'basic heat' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::rabbitmq
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

      rabbitmq_user { 'heat':
        admin    => true,
        password => 'an_even_bigger_secret',
        provider => 'rabbitmqctl',
        require  => Class['rabbitmq'],
      }

      rabbitmq_user_permissions { 'heat@/':
        configure_permission => '.*',
        write_permission     => '.*',
        read_permission      => '.*',
        provider             => 'rabbitmqctl',
        require              => Class['rabbitmq'],
      }

      class { '::heat::keystone::authtoken':
        password => 'a_big_secret',
      }
      # heat resources
      class { '::heat':
        rabbit_userid       => 'heat',
        rabbit_password     => 'an_even_bigger_secret',
        rabbit_host         => '127.0.0.1',
        database_connection => 'mysql+pymysql://heat:a_big_secret@127.0.0.1/heat?charset=utf8',
        debug               => true,
      }
      class { '::heat::db::mysql':
        password => 'a_big_secret',
      }
      class { '::heat::keystone::auth':
        password                  => 'a_big_secret',
        configure_delegated_roles => true,
      }
      class { '::heat::keystone::domain':
        domain_password => 'oh_my_no_secret',
      }
      class { '::heat::client': }
      class { '::heat::api': }
      class { '::heat::engine':
        auth_encryption_key => '1234567890AZERTYUIOPMLKJHGFDSQ12',
      }
      class { '::heat::api_cloudwatch': }
      class { '::heat::api_cfn': }
      class { '::heat::cron::purge_deleted': }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(8000) do
      it { is_expected.to be_listening.with('tcp') }
    end

    describe port(8003) do
      it { is_expected.to be_listening.with('tcp') }
    end

    describe port(8004) do
      it { is_expected.to be_listening.with('tcp') }
    end

    describe cron do
      it { is_expected.to have_entry('1 0 * * * heat-manage purge_deleted -g days 1 >>/var/log/heat/heat-purge_deleted.log 2>&1').with_user('heat') }
    end
  end
end
