require 'spec_helper'

describe 'ovirt::node::firewall' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:pre_condition) { "class { 'ovirt::node': }" }

  it { should create_class('ovirt::node::firewall') }
  it { should contain_class('ovirt::node') }

  it do
    should contain_firewall('100 vdsm').with({
      :dport    => '54321',
      :proto    => 'tcp',
      :action   => 'accept',
      :chain    => 'INPUT',
    })
  end

  it do
    should contain_firewall('101 snmp').with({
      :dport    => '161',
      :proto    => 'udp',
      :action   => 'accept',
      :chain    => 'INPUT',
    })
  end

  it do
    should contain_firewall('102 libvirt tls').with({
      :dport    => '16514',
      :proto    => 'tcp',
      :action   => 'accept',
      :chain    => 'INPUT',
    })
  end

  it do
    should contain_firewall('103 guest consoles').with({
      :dport    => '5900-6923',
      :proto    => 'tcp',
      :action   => 'accept',
      :chain    => 'INPUT',
    })
  end

  it do
    should contain_firewall('104 migration').with({
      :dport    => '49152-49216',
      :proto    => 'tcp',
      :action   => 'accept',
      :chain    => 'INPUT',
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
