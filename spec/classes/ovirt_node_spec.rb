require 'spec_helper'

describe 'ovirt::node' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt::node') }
  it { should contain_class('ovirt') }
  it { should contain_class('sudo') }
  it { should contain_class('ovirt::node::firewall') }

  it do
    should contain_package('vdsm').with({
      'ensure'  => 'installed',
      'name'    => 'vdsm',
      'require' => 'Package[ovirt-release]',
    })
  end

  it { should contain_package('vdsm').that_comes_before('File[/etc/vdsm/vdsm.conf]') }
  it { should contain_package('vdsm').that_comes_before('File[/etc/vdsm/vdsm.id]') }
  it { should contain_package('vdsm').that_comes_before('Vdsm_config[addresses/management_port]') }
  it { should contain_package('vdsm').that_comes_before('Vdsm_config[vars/ssl]') }

  it do
    should contain_file('/etc/vdsm/vdsm.conf').only_with({
      'path'    => '/etc/vdsm/vdsm.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end

  it do
    should contain_file('/etc/vdsm/vdsm.id').only_with({
      'ensure'  => 'present',
      'path'    => '/etc/vdsm/vdsm.id',
      'source'  => '/proc/sys/kernel/random/uuid',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0444',
      'replace' => 'false',
      'before'  => 'Service[vdsmd]',
    })
  end

  it do
    should contain_service('vdsmd').only_with({
      'ensure'      => 'running',
      'name'        => 'vdsmd',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'subscribe'   => 'File[/etc/vdsm/vdsm.conf]',
    })
  end

  it do
    should contain_sudo__conf('vdsm').with({
      'ensure'    => 'present',
      'priority'  => '50',
      'before'    => 'Service[vdsmd]',
    })
  end

  it { should have_vdsm_config_resource_count(2) }

  it { should contain_vdsm_config('addresses/management_port').with_value('54321') }
  it { should contain_vdsm_config('vars/ssl').with_value('true') }

  [
    'addresses/management_port',
    'vars/ssl',
  ].each do |name|
    it { should contain_vdsm_config(name).that_comes_before('File[/etc/vdsm/vdsm.conf]') }
    it { should contain_vdsm_config(name).that_notifies('Service[vdsmd]') }
  end

  context 'when manage_firewall => false' do
    let(:params) {{ :manage_firewall => false }}
    it { should_not contain_class('ovirt::node::firewall') }
  end

  context 'when vdsm_configs is Hash' do
    let :params do
      {
        :vdsm_configs => {'addresses/management_ip' => {'value' => '0.0.0.0'}},
      }
    end

    it { should have_vdsm_config_resource_count(3) }
    it { should contain_vdsm_config('addresses/management_ip').with_value('0.0.0.0') }
    it { should contain_vdsm_config('addresses/management_ip').that_comes_before('File[/etc/vdsm/vdsm.conf]') }
    it { should contain_vdsm_config('addresses/management_ip').that_notifies('Service[vdsmd]') }
  end

  context 'when vdsm_configs is "foo"' do
    let(:params) {{ :vdsm_configs => "foo" }}
    it { expect { should create_class('ovirt::node') }.to raise_error(Puppet::Error, /is not a Hash/) }
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
