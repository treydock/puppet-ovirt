require 'spec_helper_acceptance'

describe 'vdsm_config type' do
  context 'set irs/nfs_mount_options' do
    it 'should run successfully' do
      pp =<<-EOS
        vdsm_config { 'addresses/management_ip': value => '0.0.0.0' }
      EOS
  
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/etc/vdsm/vdsm.conf') do
      its(:content) { should match /^management_ip = 0.0.0.0/ }
    end
  end
end
