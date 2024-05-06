require 'spec_helper'

describe 'Heat::AuthEncryptionKey' do
  describe 'valid types' do
    context 'with valid types' do
      [
        '0123456789abcdef',
        '0123456789abcdefghijklmn',
        '0123456789abcdefghijklmnopqrstuv'
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end
  end

  describe 'invalid types' do
    context 'with garbage inputs' do
      [
        1234567890123456,
        true,
        false,
        nil,
        {'0123456789abcdefghijklmnopqrstuv' => '0123456789abcdefghijklmnopqrstuv'},
        ['0123456789abcdefghijklmnopqrstuv'],
        '0123456789abcde',
        '0123456789abcdefg',
        '0123456789abcdefghijklm',
        '0123456789abcdefghijklmno',
        '0123456789abcdefghijklmnopqrstu',
        '0123456789abcdefghijklmnopqrstuvw',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
