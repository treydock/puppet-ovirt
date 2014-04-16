require 'spec_helper'

describe 'ovirt::node::firewall::post' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:pre_condition) { "class { 'ovirt::node': }" }

  it { should create_class('ovirt::node::firewall::post') }

  it do
    should contain_firewall('998 reject all').with({
      :action   => 'reject',
      :proto    => 'all',
      :reject   => 'icmp-host-prohibited',
      :before   => nil,
      :require  => 'Class[Ovirt::Node::Firewall::Pre]',
    })
  end
end
