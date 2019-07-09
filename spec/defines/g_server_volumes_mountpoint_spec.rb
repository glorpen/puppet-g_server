require 'spec_helper'

describe 'G_server::Volumes::Mountpoint' do
  let(:title) { '/mnt/example' }

  describe 'when creating' do
    let(:params) do
      {
        'ensure' => 'present',
      }
    end
    let(:pre_condition) do
      [
        'lvm::logical_volume { "lv": volume_group => "vg", size => "1G", mountpath => "/mnt/example", mountpath_require => false }',
        'group { "example": }',
        'user { "example": gid => "example"}',
        'file { "/mnt": ensure => directory }',
      ]
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_user('example').that_requires('Group[example]') }

    context 'with mode' do
      let(:params) do
        super().merge(mode: 'a=rwx')
      end

      it { is_expected.to contain_file('/mnt/example').with('mode' => 'a=rwx') }
    end

    context 'with specific user name' do
      let(:params) do
        super().merge(user: 'example')
      end

      it { is_expected.to contain_file('/mnt/example').that_requires('User[example]') }
    end
    context 'with specific user name' do
      let(:params) do
        super().merge(user: 'example', group: 'example')
      end

      it { is_expected.to contain_file('/mnt/example').that_requires('User[example]').that_requires('Group[example]') }
    end
    context 'with specific group' do
      let(:params) do
        super().merge(group: 'example')
      end

      it { is_expected.to contain_file('/mnt/example').that_requires('Group[example]') }
    end
    context 'with specific user and group ids' do
      let(:params) do
        super().merge(user: 1234, group: 1234)
      end

      it { is_expected.to contain_file('/mnt/example') }
    end

    context 'with mountpoint related to LVM volume' do
      it { is_expected.to contain_mount('/mnt/example').that_requires('File[/mnt/example]') }
    end
  end

  context 'when removing' do
    let(:params) do
      {
        'ensure' => 'absent',
      }
    end
    let(:pre_condition) do
      [
        'lvm::logical_volume { "lv": ensure => absent, volume_group => "vg", size => "1G", mountpath => "/mnt/example", mountpath_require => false }',
        'file { "/mnt": ensure => directory }',
      ]
    end

    it { is_expected.to contain_exec("ensure mountpoint '/mnt/example' exists").with('unless' => 'true') }
    it { is_expected.to contain_mount('/mnt/example').that_comes_before('Exec[g_server remove vol mountpoint /mnt/example]') }
  end
end
