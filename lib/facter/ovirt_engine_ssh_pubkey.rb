# Fact: ovirt_engine_ssh_pubkey
#
# Purpose: Return the oVirt Engine SSH public key fact.
#

require 'facter/util/ovirt'



Facter.add(:ovirt_engine_ssh_pubkey) do
  confine :osfamily => 'RedHat'

  engine_cert = "/etc/pki/ovirt-engine/certs/engine.cer"

  setcode do
    if cert = Facter::Util::Ovirt.read_certificate(engine_cert)
      pubkey = Facter::Util::Ovirt.engine_ssh_public_key(cert)
      pubkey
    end
  end
end
