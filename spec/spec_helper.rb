require 'puppetlabs_spec_helper/module_spec_helper'

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

