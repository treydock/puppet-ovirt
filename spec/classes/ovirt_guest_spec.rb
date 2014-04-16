require 'spec_helper'

describe 'ovirt::guest' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt::guest') }
  it { should contain_class('ovirt::params') }
  it { should contain_class('epel') }

  it do
    should contain_package('qemu-guest-agent').with_ensure('present')
  end

  it do
    should contain_service('qemu-ga').with({
      :ensure     => 'running',
      :enable     => 'true',
      :name       => 'qemu-ga',
      :hasstatus  => 'true',
      :hasrestart => 'true',
      :require    => 'Package[qemu-guest-agent]',
    })
  end

  it do
    should contain_package('ovirt-guest-agent').with({
      :ensure   => 'present',
      :name     => 'ovirt-guest-agent',
      :before   => 'Service[ovirt-guest-agent]',
      :require  => 'Yumrepo[epel]',
    })
  end

  it do
    should contain_service('ovirt-guest-agent').with({
      :ensure     => 'running',
      :enable     => 'true',
      :name       => 'ovirt-guest-agent',
      :hasstatus  => 'true',
      :hasrestart => 'true',
    })
  end

  context 'when manage_qemu_guest_agent => false' do
    let(:params) {{ :manage_qemu_guest_agent => false }}
    it { should_not contain_package('qemu-guest-agent') }
    it { should_not contain_service('qemu-ga') }
  end

  # Test boolean validation
  [
    'manage_qemu_guest_agent',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('ovirt::guest') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
