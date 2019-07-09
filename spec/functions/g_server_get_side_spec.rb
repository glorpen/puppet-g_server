require 'spec_helper'

describe 'g_server::get_side', type: :puppet_function do
  let(:pre_condition) { 'class { "g_server": external_ifaces => ["OUT"], internal_ifaces => ["IN"]}' }

  context 'should split available interfaces' do
    it { is_expected.to run.with_params('dummyXX').and_return('none') }
    it { is_expected.to run.with_params('IN').and_return('internal') }
    it { is_expected.to run.with_params('OUT').and_return('external') }
  end
end
