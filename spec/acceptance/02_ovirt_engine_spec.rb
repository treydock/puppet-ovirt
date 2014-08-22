require 'spec_helper_acceptance'

describe 'ovirt::engine class' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'ovirt': }
        class { 'ovirt::engine': }
      EOS
  
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe package('ovirt-engine') do
      it { should be_installed }
    end
  end
end
