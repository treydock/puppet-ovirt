require 'spec_helper'

describe 'ovirt::node' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt::node') }
  it { should contain_class('ovirt') }
  it { should contain_class('ovirt::repo') }
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

  it { should contain_file('/etc/pki/vdsm').with_ensure('directory').that_comes_before('File[/etc/pki/vdsm/certs]') }
  it { should contain_file('/etc/pki/vdsm/certs').with_ensure('directory').that_comes_before('File[/root/ovirt_node_register.sh]') }
  it do
    should contain_file('/root/ovirt_node_register.sh').with({
      :ensure   => 'file',
      :require  => 'File[/etc/vdsm/vdsm.id]',
    })
  end

  # TODO : Test ovirt_node_register.sh content

  it do
    should contain_file('/etc/ovirt-host-deploy.conf.d') \
      .with_ensure('directory') \
      .that_comes_before('File[/etc/ovirt-host-deploy.conf.d/40-custom-vdsm-config.conf]')
  end

  it do
    should contain_file('/etc/ovirt-host-deploy.conf.d/40-custom-vdsm-config.conf').with({
      :ensure   => 'file',
      :content  => '',
    })
  end

  context 'when vdsm_configs defined' do
    let(:params) {{ :vdsm_configs => ['irs/iscsi_default_ifaces=str:iser,default'] }}

    it "40-custom-vdsm-config.conf should contain VDSM_CONFIG" do
      should contain_file('/etc/ovirt-host-deploy.conf.d/40-custom-vdsm-config.conf').with({
        :content  => /^VDSM_CONFIG\/irs\/iscsi_default_ifaces=str:iser,default$/,
      })
    end
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
