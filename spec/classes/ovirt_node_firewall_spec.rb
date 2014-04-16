require 'spec_helper'

describe 'ovirt::node::firewall' do
  include_context :defaults

  let(:facts) { default_facts }

  let(:pre_condition) { "class { 'ovirt::node': }" }

  it { should create_class('ovirt::node::firewall') }
  it { should contain_class('ovirt::node::firewall::pre') }
  it { should contain_class('ovirt::node::firewall::app') }
  it { should contain_class('ovirt::node::firewall::post') }
  it { should contain_class('firewall') }

  it { should contain_resources('firewall').with_purge('false') }
end
