require 'puppetlabs_spec_helper/module_spec_helper'

ver = Gem::Version.new(Puppet.version.split('-').first)
if Gem::Requirement.new("~> 3.0.0") =~ ver
  puts "ovirt: setting LOAD_PATH to work around broken type autoloading"
  fixtures_dir = File.join(File.dirname(__FILE__),  'fixtures')
  $LOAD_PATH.unshift(File.join(fixtures_dir, 'modules/stdlib/lib'))
end

shared_context :defaults do
  let(:node) { 'foo.example.com' }

  let :default_facts do
    {
      :kernel                 => 'Linux',
      :osfamily               => 'RedHat',
      :operatingsystem        => 'CentOS',
      :operatingsystemrelease => '6.4',
      :architecture           => 'x86_64',
      :domain                 => 'example.com',
      :fqdn                   => 'foo.example.com',
    }
  end
end

at_exit { RSpec::Puppet::Coverage.report! }

