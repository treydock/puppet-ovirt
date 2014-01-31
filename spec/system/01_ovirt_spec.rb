require 'spec_helper_system'

describe 'ovirt class:' do
  context 'with default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'ovirt': }
      EOS
  
      puppet_apply(pp) do |r|
       r.exit_code.should_not == 1
       r.refresh
       r.exit_code.should be_zero
      end
    end

    describe yumrepo('ovirt-stable') do
      it { should exist }
      it { should be_enabled }
    end

    describe yumrepo('glusterfs-epel') do
      it { should exist }
      it { should be_enabled }
    end

    describe yumrepo('glusterfs-noarch-epel') do
      it { should exist }
      it { should be_enabled }
    end
  end
end
