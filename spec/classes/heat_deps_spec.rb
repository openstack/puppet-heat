require 'spec_helper'

describe 'heat::deps' do

  it 'set up the anchors' do
    is_expected.to contain_anchor('heat::install::begin')
    is_expected.to contain_anchor('heat::install::end')
    is_expected.to contain_anchor('heat::config::begin')
    is_expected.to contain_anchor('heat::config::end')
    is_expected.to contain_anchor('heat::db::begin')
    is_expected.to contain_anchor('heat::db::end')
    is_expected.to contain_anchor('heat::dbsync::begin')
    is_expected.to contain_anchor('heat::dbsync::end')
    is_expected.to contain_anchor('heat::service::begin')
    is_expected.to contain_anchor('heat::service::end')
  end
end
