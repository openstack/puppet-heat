require 'spec_helper_acceptance'

describe 'basic heat_config resource' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      File <||> -> Heat_config <||>
      File <||> -> Heat_api_paste_ini <||>

      file { '/etc/heat' :
        ensure => directory,
      }
      file { '/etc/heat/heat.conf' :
        ensure => file,
      }
      file { '/etc/heat/api-paste.ini' :
        ensure => file,
      }

      heat_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      heat_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      heat_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      heat_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      heat_config { 'DEFAULT/thisshouldexist3' :
        value => ['foo', 'bar'],
      }

      heat_api_paste_ini { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      heat_api_paste_ini { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      heat_api_paste_ini { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      heat_api_paste_ini { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      heat_api_paste_ini { 'DEFAULT/thisshouldexist3' :
        value             => 'foo',
        key_val_separator => ':'
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/etc/heat/heat.conf') do
      it { is_expected.to exist }
      it { is_expected.to contain('thisshouldexist=foo') }
      it { is_expected.to contain('thisshouldexist2=<SERVICE DEFAULT>') }
      it { is_expected.to contain('thisshouldexist3=foo') }
      it { is_expected.to contain('thisshouldexist3=bar') }

      describe '#content' do
        subject { super().content }
        it { is_expected.to_not match /thisshouldnotexist/ }
      end
    end

    describe file('/etc/heat/api-paste.ini') do
      it { is_expected.to exist }
      it { is_expected.to contain('thisshouldexist=foo') }
      it { is_expected.to contain('thisshouldexist2=<SERVICE DEFAULT>') }
      it { is_expected.to contain('thisshouldexist3:foo') }

      describe '#content' do
        subject { super().content }
        it { is_expected.to_not match /thisshouldnotexist/ }
      end
    end
  end
end
