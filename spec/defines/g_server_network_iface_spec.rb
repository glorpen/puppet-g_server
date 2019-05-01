require 'spec_helper'

describe 'G_server::Network::Iface' do
  let(:title) { 'eth0' }

  it { is_expected.to compile.with_all_deps }

  context 'with defaults' do
    it { is_expected.to contain_network__interface('eth0') }
  end

  context 'with ipv4 route' do
    let(:params) do
      {
        'routes' => [
          { 'ipaddress' => '10.0.0.1', 'cidr' => '255.255.255.0' },
        ],
      }
    end

    it { is_expected.to contain_network__route('eth0').with_family(['inet4']).with_cidr([nil]) }
  end

  context 'with ipv4 route and no netmask' do
    let(:params) do
      {
        'routes' => [
          { 'ipaddress' => '10.0.0.1', 'cidr' => 32 },
        ],
      }
    end

    it { is_expected.to contain_network__route('eth0').with_family(['inet4']).with_cidr([32]).with_netmask(['255.255.255.255']) }
  end

  context 'with ipv6 route' do
    let(:params) do
      {
        'routes' => [
          { 'ipaddress' => '::', 'cidr' => 64 },
        ],
      }
    end

    it { is_expected.to contain_network__route('eth0').with_family(['inet6']).with_cidr([64]) }
  end
end
