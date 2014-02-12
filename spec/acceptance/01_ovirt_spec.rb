require 'spec_helper_acceptance'

describe 'ovirt class' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'ovirt': }
      EOS
  
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe yumrepo('glusterfs-epel') do
      it { should exist }
      it { should be_enabled }
    end

    describe yumrepo('glusterfs-noarch-epel') do
      it { should exist }
      it { should be_enabled }
    end

    describe yumrepo('ovirt-stable') do
      it { should exist }
      it { should be_enabled }
    end

    describe yumrepo('ovirt-3.3.3') do
      it { should exist }
      it { should be_enabled }
    end
  end
end
