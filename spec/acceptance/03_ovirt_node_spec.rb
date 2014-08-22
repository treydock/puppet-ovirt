require 'spec_helper_acceptance'

describe 'ovirt::node class' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'sudo': purge => false, config_file_replace => false }
        class { 'ovirt': }
        class { 'ovirt::node': }
      EOS
  
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/etc/vdsm/vdsm.id') do
      it { should be_file }
    end

    describe file('/etc/sudoers.d/50_vdsm') do
      it { should be_file }
    end
  end
end
