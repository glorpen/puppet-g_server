require 'spec_helper'

describe 'G_server::Services::Ssh' do
  context 'with defaults' do
    it { is_expected.to compile }
  end
  context 'with ciphers' do
    let(:params) { { 'ciphers' => ['test1', 'test2'] } }

    it 'sets given ciphers' do
      options = catalogue.resource('class', 'ssh::server').send(:parameters)[:options]
      expect(options).to include('Ciphers' => 'test1,test2')
    end
  end
end
