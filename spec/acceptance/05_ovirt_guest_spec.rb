require 'spec_helper_acceptance'

describe 'ovirt::guest class' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'ovirt::guest': }
      EOS
  
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe package('qemu-guest-agent') do
      it { should_not be_installed }
    end

    describe package('ovirt-guest-agent') do
      it { should_not be_installed }
    end

    describe service('qemu-ga') do
      it { should_not be_running }
      it { should_not be_enabled }
    end

    describe service('ovirt-guest-agent') do
      it { should_not be_running }
      it { should_not be_enabled }
    end
  end
end
