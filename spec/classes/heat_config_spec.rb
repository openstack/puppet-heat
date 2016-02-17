require 'spec_helper'

describe 'heat::config' do

  let :params do
    { :heat_config => {
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

  it 'configures arbitrary heat configurations' do
    is_expected.to contain_heat_config('DEFAULT/foo').with_value('fooValue')
    is_expected.to contain_heat_config('DEFAULT/bar').with_value('barValue')
    is_expected.to contain_heat_config('DEFAULT/baz').with_ensure('absent')
  end

  it 'configures arbitrary heat-api-paste configurations' do
    is_expected.to contain_heat_api_paste_ini('DEFAULT/foo2').with_value('fooValue')
    is_expected.to contain_heat_api_paste_ini('DEFAULT/bar2').with_value('barValue')
    is_expected.to contain_heat_api_paste_ini('DEFAULT/baz2').with_ensure('absent')
  end

end
