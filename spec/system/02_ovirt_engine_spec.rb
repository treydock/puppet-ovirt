require 'spec_helper_system'

describe 'ovirt::engine class:' do
  context 'with default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'ovirt::engine': }
      EOS
  
      puppet_apply(pp) do |r|
       r.exit_code.should_not == 1
       r.refresh
       r.exit_code.should be_zero
      end
    end

    describe package('ovirt-engine') do
      it { should be_installed }
    end
  end
end
