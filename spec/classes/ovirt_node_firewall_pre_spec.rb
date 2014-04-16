require 'spec_helper'

describe 'ovirt::node::firewall::pre' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:pre_condition) { "class { 'ovirt::node': }" }

  it { should create_class('ovirt::node::firewall::pre') }

  it do
    should contain_firewall('000 accept all icmp').with({
      :proto    => 'icmp',
      :action   => 'accept',
      :before   => 'Firewall[001 accept all to lo interface]',
      :require  => nil,
    })
  end

  it do
    should contain_firewall('001 accept all to lo interface').with({
      :proto    => 'all',
      :iniface  => 'lo',
      :action   => 'accept',
      :before   => 'Firewall[002 accept related established rules]',
      :require  => nil,
    })
  end

  it do
    should contain_firewall('002 accept related established rules').with({
      :proto    => 'all',
      :state    => ['RELATED','ESTABLISHED'],
      :action   => 'accept',
      :before   => 'Firewall[003 accept new ssh]',
      :require  => nil,
    })
  end

  it do
    should contain_firewall('003 accept new ssh').with({
      :proto    => 'tcp',
      :action   => 'accept',
      :dport    => '22',
      :before   => 'Class[Ovirt::Node::Firewall::Post]',
      :require  => nil,
    })
  end
end
