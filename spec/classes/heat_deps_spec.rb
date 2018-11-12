require 'spec_helper'

describe 'heat::deps' do
  shared_examples 'heat::deps' do
    it {
      should contain_anchor('heat::install::begin')
      should contain_anchor('heat::install::end')
      should contain_anchor('heat::config::begin')
      should contain_anchor('heat::config::end')
      should contain_anchor('heat::db::begin')
      should contain_anchor('heat::db::end')
      should contain_anchor('heat::dbsync::begin')
      should contain_anchor('heat::dbsync::end')
      should contain_anchor('heat::service::begin')
      should contain_anchor('heat::service::end')
    }
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'heat::deps'
    end
  end
end
