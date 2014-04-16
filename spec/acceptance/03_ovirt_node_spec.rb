require 'spec_helper_acceptance'

describe 'ovirt::node class' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
      class { 'sudo': purge => false, config_file_replace => false }
      class { 'ovirt::node': }
      EOS
  
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package('vdsm') do
      it { should be_installed }
    end

    describe file('/etc/vdsm/vdsm.conf') do
      it { should be_file }
    end

    describe file('/etc/sudoers.d/50_vdsm') do
      it { should be_file }
    end
  end
end
