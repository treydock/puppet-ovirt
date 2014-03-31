require 'spec_helper'

describe 'ovirt::node::firewall' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt::node::firewall') }
  it { should contain_class('ovirt::node') }

  it { should have_firewall_resource_count(9) }  

  it do
    should contain_firewall('001 allow established,related').with({
      :ensure => 'present',
      :action => 'accept',
      :chain  => 'INPUT',
      :state  => ['ESTABLISHED','RELATED'],
      :proto  => 'all',
    })
  end

  it do
    should contain_firewall('002 allow loopback access').with({
      :ensure   => 'present',
      :action   => 'accept',
      :chain    => 'INPUT',
      :iniface  => 'lo',
      :proto    => 'all',
    })
  end

  [
    {:name => '100 vdsm', :port => '54321', :proto => 'tcp'},
    {:name => '101 ssh', :port => '22', :proto => 'tcp'},
    {:name => '102 snmp', :port => '161', :proto => 'udp'},
    {:name => '103 libvirt tls', :port => '16514', :proto => 'tcp'},
    {:name => '104 guest consoles', :port => '5900-6923', :proto => 'tcp'},
    {:name => '105 migration', :port => '49152-49216', :proto => 'tcp'},
  ].each do |fw|
    it do
      should contain_firewall(fw[:name]).with({
        :ensure => 'present',
        :action => 'accept',
        :chain  => 'INPUT',
        :dport  => fw[:port],
        :proto  => fw[:proto],
      })
    end
  end

  it do
    should contain_firewall('998 reject').with({
      :ensure   => 'present',
      :action   => 'reject',
      :chain    => 'INPUT',
      :proto    => 'all',
      :reject   => 'icmp-host-prohibited',
    })
  end

  context 'when ovirt::node::management_port => "12345"' do
    let :pre_condition do
      "class { 'ovirt::node':
        management_port => '12345',
      }"
    end

    it { should contain_firewall('100 vdsm').with_dport('12345') }
  end
end
