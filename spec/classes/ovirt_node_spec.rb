require 'spec_helper'

describe 'ovirt::node' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt::node') }
  it { should contain_class('ovirt') }
  it { should contain_class('sudo') }
  it { should contain_class('ovirt::node::firewall') }

  it { should have_vdsm_config_resource_count(0) }

  it do
    should contain_file('/etc/vdsm') \
      .with_ensure('directory') \
      .that_comes_before('File[/etc/vdsm/vdsm.id]')
  end

  it do
    should contain_file('/etc/vdsm/vdsm.id').only_with({
      :ensure   => 'file',
      :path     => '/etc/vdsm/vdsm.id',
      :source   => '/proc/sys/kernel/random/uuid',
      :owner    => 'root',
      :group    => 'root',
      :mode     => '0444',
      :replace  => 'false',
    })
  end

  it do
    should contain_sudo__conf('vdsm').with({
      :ensure     => 'present',
      :priority   => '50',
    })
  end

  context 'when manage_firewall => false' do
    let(:params) {{ :manage_firewall => false }}
    it { should_not contain_class('ovirt::node::firewall') }
  end

  # Test boolean validation
  [
    :manage_firewall,
    :storeconfigs_enabled,
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param => 'foo' }}
      it { expect { should create_class('ovirt::node') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
