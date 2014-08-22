require 'spec_helper'
require 'facter/util/ovirt'

describe 'ovirt_engine_ssh_pubkey Fact' do
  before :each do
    Facter.clear
    Facter.fact(:osfamily).stubs(:value).returns("RedHat")
    @cert = my_fixture_read('engine.cer')
    @public_key = "AAAAB3NzaC1yc2EAAAADAQABAAABAQCte/R3v00CijA/UMqM7zzYaejGpCk+bDLQ8oE/cJG0ngORgRKNm1bv6NNg85iQYUIA3746E0v9U58EBCMjL1DGxTs79YlBSVSyElJd6WRvG1mGUjEQNYdrIf/F/z0SLcBcaQrmr1CkA8MHnEDR2IJLLQcmwfv3poHatWdjGgWtwn5xGAVjHErDtNI3gDMWz1kvCYfqzJucrS/RVeZb96B5BxoKgf/ULdixExcWPNpvC0VLGPq9wXykiphLukJTIo4aVbqkst9OxNWLU5ogDDKPHldZnWWuRv/8donzJPAAXP/5vB+XghKlHPHN5OrXKT8W4mnKGV3l0ROr2ik5babN"
  end

  it "should return public_key" do
    Facter::Util::Ovirt.expects(:read_certificate).with("/etc/pki/ovirt-engine/certs/engine.cer").returns(@cert)
    Facter::Util::Ovirt.stubs(:engine_ssh_public_key).with(@cert).returns(@public_key)
    Facter.fact(:ovirt_engine_ssh_pubkey).value.should == @public_key
  end

  it "should return nil" do
    Facter::Util::Ovirt.expects(:read_certificate).with("/etc/pki/ovirt-engine/certs/engine.cer").returns(nil)
    Facter.fact(:ovirt_engine_ssh_pubkey).value.should == nil
  end
end
