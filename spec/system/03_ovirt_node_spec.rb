require 'spec_helper_system'

describe 'ovirt::node class:' do
  context 'with default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'ovirt::node': }
      EOS
  
      puppet_apply(pp) do |r|
       r.exit_code.should_not == 1
       r.refresh
       r.exit_code.should be_zero
      end
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
