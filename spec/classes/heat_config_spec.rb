require 'spec_helper'

describe 'heat::config' do

  let :params do
    {
      :heat_config        => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      },
      :heat_api_paste_ini => {
        'DEFAULT/foo2' => { 'value'  => 'fooValue' },
        'DEFAULT/bar2' => { 'value'  => 'barValue' },
        'DEFAULT/baz2' => { 'ensure' => 'absent' }
      }
    }
  end

  shared_examples 'heat::config' do
    it { should contain_class('heat::deps') }

    it {
      should contain_heat_config('DEFAULT/foo').with_value('fooValue')
      should contain_heat_config('DEFAULT/bar').with_value('barValue')
      should contain_heat_config('DEFAULT/baz').with_ensure('absent')
    }

    it {
      should contain_heat_api_paste_ini('DEFAULT/foo2').with_value('fooValue')
      should contain_heat_api_paste_ini('DEFAULT/bar2').with_value('barValue')
      should contain_heat_api_paste_ini('DEFAULT/baz2').with_ensure('absent')
    }
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'heat::config'
    end
  end
end
