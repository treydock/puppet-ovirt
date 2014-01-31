require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'
require 'rspec-system-serverspec/helpers'

include RSpecSystemPuppet::Helpers
include Serverspec::Helper::RSpecSystem
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  # Project root for this module
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Enable colour in Jenkins
  c.tty = true
  
  c.include RSpecSystemPuppet::Helpers

  # This is where we 'setup' the nodes before running our tests
  c.before :suite do
    # Install puppet
    puppet_install
    puppet_master_install

    shell('[ -d /etc/puppet/modules/stdlib ] || puppet module install puppetlabs/stdlib --modulepath /etc/puppet/modules --version ">=3.2.0 <5.0.0"')
    shell('[ -d /etc/puppet/modules/firewall ] || puppet module install puppetlabs/firewall --modulepath /etc/puppet/modules --version ">=0.4.2 <1.0.0"')
    shell('[ -d /etc/puppet/modules/inifile ] || puppet module install puppetlabs/inifile --modulepath /etc/puppet/modules --version ">=1.0.0 <2.0.0"')
    shell('[ -d /etc/puppet/modules/sudo ] || puppet module install saz/sudo --modulepath /etc/puppet/modules --version ">=2.0.0 <4.0.0"')
    shell('[ -d /etc/puppet/modules/epel ] || puppet module install stahnma/epel --modulepath /etc/puppet/modules --version ">=0.0.1 <1.0.0"')
    
    # Install ovirt module
    puppet_module_install(:source => proj_root, :module_name => 'ovirt')
  end
end
