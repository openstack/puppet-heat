require 'spec_helper'

describe 'heat::policy' do

  shared_examples_for 'heat policies' do
    let :params do
      {
        :policy_path => '/etc/heat/policy.json',
        :policies    => {
          'context_is_admin' => {
            'key'   => 'context_is_admin',
            'value' => 'foo:bar'
          }
        }
      }
    end

    it 'set up the policies' do
      is_expected.to contain_openstacklib__policy__base('context_is_admin').with({
        :key        => 'context_is_admin',
        :value      => 'foo:bar',
        :file_user  => 'root',
        :file_group => 'heat',
      })
      is_expected.to contain_oslo__policy('heat_config').with(
        :policy_file => '/etc/heat/policy.json',
      )
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'heat policies'
    end
  end
end
