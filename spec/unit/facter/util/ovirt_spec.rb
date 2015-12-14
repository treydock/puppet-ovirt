require 'spec_helper'
require 'facter/util/file_read'
require 'facter/util/ovirt'

describe 'Facter::Util::Ovirt' do

  SSH_PUBLIC_KEY = "AAAAB3NzaC1yc2EAAAADAQABAAABAQCte/R3v00CijA/UMqM7zzYaejGpCk+bDLQ8oE/cJG0ngORgRKNm1bv6NNg85iQYUIA3746E0v9U58EBCMjL1DGxTs79YlBSVSyElJd6WRvG1mGUjEQNYdrIf/F/z0SLcBcaQrmr1CkA8MHnEDR2IJLLQcmwfv3poHatWdjGgWtwn5xGAVjHErDtNI3gDMWz1kvCYfqzJucrS/RVeZb96B5BxoKgf/ULdixExcWPNpvC0VLGPq9wXykiphLukJTIo4aVbqkst9OxNWLU5ogDDKPHldZnWWuRv/8donzJPAAXP/5vB+XghKlHPHN5OrXKT8W4mnKGV3l0ROr2ik5babN"

  before :each do
    Facter.clear
  end

  describe 'read_certificate' do
    it 'should return content' do
      Facter::Util::FileRead.stubs(:read).with(my_fixture('engine.cer')).returns(my_fixture_read('engine.cer'))
      Facter::Util::Ovirt.read_certificate(my_fixture('engine.cer')).should == my_fixture_read('engine.cer')
    end

    it 'should return nil' do
      Facter::Util::FileRead.stubs(:read).with(my_fixture('engine.cer')).returns(nil)
      Facter::Util::Ovirt.read_certificate(my_fixture('engine.cer')).should be_nil
    end
  end

  describe 'engine_ssh_public_key' do
    it 'should return public key' do
      @cert = OpenSSL::X509::Certificate.new(my_fixture_read('engine.cer'))
      OpenSSL::X509::Certificate.stubs(:new).with(my_fixture_read('engine.cer')).returns(@cert)
      Facter::Util::Ovirt.engine_ssh_public_key(my_fixture_read('engine.cer')).should == SSH_PUBLIC_KEY
    end
  end
end
