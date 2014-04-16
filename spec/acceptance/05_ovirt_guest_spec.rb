require 'spec_helper_acceptance'

describe 'ovirt::guest class' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
      class { 'ovirt::guest': agent_service_ensure => 'stopped', qemu_guest_agent_ensure => 'stopped' }
      EOS
  
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package('qemu-guest-agent') do
      it { should be_installed }
    end

    describe package('ovirt-guest-agent') do
      it { should be_installed }
    end

    describe service('qemu-ga') do
      it { should_not be_running }
      it { should be_enabled }
    end

    describe service('ovirt-guest-agent') do
      it { should_not be_running }
      it { should be_enabled }
    end
  end
end
