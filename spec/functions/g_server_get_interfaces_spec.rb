require 'spec_helper'

describe 'g_server::get_interfaces', type: :puppet_function do
  let(:pre_condition) { 'class { "g_server": external_ifaces => ["OUT"], internal_ifaces => ["IN"]}' }

  context 'should list available interfaces' do
    it { is_expected.to run.with_params('none').and_return([]) }
    it { is_expected.to run.with_params('internal').and_return(['IN']) }
    it { is_expected.to run.with_params('external').and_return(['OUT']) }
    it { is_expected.to run.with_params('both').and_return(['IN', 'OUT']) }
  end
end
