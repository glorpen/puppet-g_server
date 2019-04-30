require 'spec_helper'

describe 'G_server::Network::Iface' do
  let(:title) { 'eth0' }

  it { is_expected.to compile.with_all_deps }

  context 'with os => CentOS' do
    it { is_expected.to contain_network__interface('eth0') }
  end
end
