require 'spec_helper'

describe 'G_server::Services::Ssh' do
  context 'with defaults' do
    it { is_expected.to compile }
  end
  context 'with ciphers' do
    let(:params) do
      {
        'ciphers' => ['test1', 'test2'],
        'accept_env' => ['env1', 'env2'],
        'macs' => ['mac1', 'mac2'],
        'kex_algorithms' => ['kex1', 'kex2'],
      }
    end

    it 'with array of options' do
      options = catalogue.resource('class', 'ssh::server').send(:parameters)[:options]

      expect(options).to include('Ciphers' => 'test1,test2')
      expect(options).to include('AcceptEnv' => 'env1 env2')
      expect(options).to include('MACs' => 'mac1,mac2')
      expect(options).to include('KexAlgorithms' => 'kex1,kex2')
    end
  end
end
