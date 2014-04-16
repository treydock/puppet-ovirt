require 'puppetlabs_spec_helper/module_spec_helper'

begin
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter '/spec/'
  end

  at_exit { RSpec::Puppet::Coverage.report! }
rescue Exception => e
  warn "Coveralls disabled"
end

RSpec.configure do |c|
  c.include PuppetlabsSpec::Files
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
      :concat_basedir         => '/tmp/ovirt',
    }
  end
end
