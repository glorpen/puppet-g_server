require 'spec_helper'

describe 'G_server::Volumes::Raid' do
  let(:title) { 'some-raid' }
  let(:params) do
    {
      'size' => '1G',
      'mountpoint' => '/mnt/example',
      'vg_name' => 'vg',
      'level' => 10,
      'stripes' => 3,
      'mirrors' => 4,
    }
  end

  it { is_expected.to compile.with_all_deps }

  context 'with defaults' do
    it { is_expected.to contain_lvm__logical_volume('some-raid').with('stripes' => 3, 'mirror' => 4, 'type' => 'raid10', 'size' => '1G') }
    it { is_expected.to contain_g_server__volumes__mountpoint('/mnt/example') }
  end
end
