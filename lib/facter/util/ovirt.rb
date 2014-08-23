require 'base64'
require 'openssl'

class Facter::Util::Ovirt

  # Returns converted key
  # REF: https://github.com/bensie/sshkey for original source of this method
  #
  # @return [String]
  #
  # @api private
  def self.ssh_public_key_conversion(key)
    typestr = "ssh-rsa"
    methods = ["e", "n"]
    pubkey = key.public_key
    methods.inject([7].pack("N") + typestr) do |pubkeystr, m|
      # Given pubkey.class == OpenSSL::BN, pubkey.to_s(0) returns an MPI
      # formatted string (length prefixed bytes). This is not supported by
      # JRuby, so we still have to deal with length and data separately.
      val = pubkey.send(m)

      # Get byte-representation of absolute value of val
      data = val.to_s(2)

      first_byte = data[0,1].unpack("c").first
      if val < 0
        # For negative values, highest bit must be set
        data[0] = [0x80 & first_byte].pack("c")
      elsif first_byte < 0
        # For positive values where highest bit would be set, prefix with \0
        data = "\0" + data
      end
      pubkeystr + [data.length].pack("N") + data
    end
  end

  # Returns the public key in SSH format
  #
  # @return [String]
  #
  # @api private
  def self.engine_ssh_public_key(content)
    cert = OpenSSL::X509::Certificate.new(content)
    key = cert.public_key
    public_key = Base64.encode64(ssh_public_key_conversion(key)).gsub("\n", "")
    public_key
  end

  # Returns the content of ovirt engine x509 certificate
  #
  # @return [String]
  #
  # @api private
  def self.read_certificate(file)
    content = Facter::Util::FileRead.read(file)
    content
  end

end
