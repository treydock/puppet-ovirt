require 'spec_helper'

describe 'ovirt::guest' do
  include_context :defaults

  let(:facts) do 
    {
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '6.5',
      :manufacturer           => 'oVirt',
    }
  end

  it { should create_class('ovirt::guest') }
  it { should contain_class('ovirt::params') }
  it { should contain_class('epel') }

  it { should have_package_resource_count(2) }
  it { should have_service_resource_count(2) }

  it do
    should contain_package('qemu-guest-agent').with({
      :ensure   => 'present',
      :name     => 'qemu-guest-agent',
      :before   => 'Service[qemu-guest-agent]',
    })
  end

  it do
    should contain_service('qemu-guest-agent').with({
      :ensure     => 'running',
      :enable     => 'true',
      :name       => 'qemu-ga',
      :hasstatus  => 'true',
      :hasrestart => 'true',
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

  context 'when manage_qemu_agent => false' do
    let(:params) {{ :manage_qemu_agent => false }}
    it { should have_package_resource_count(1) }
    it { should have_service_resource_count(1) }
    it { should_not contain_package('qemu-guest-agent') }
    it { should_not contain_service('qemu-guest-agent') }
  end

  context 'when operatingsystemrelease => 7.0.1406' do
    let(:facts) do 
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '7.0.1406',
        :manufacturer           => 'oVirt',
      }
    end

    it { should contain_service('qemu-guest-agent').with_name('qemu-guest-agent') }
    it { should contain_package('ovirt-guest-agent').with_name('ovirt-guest-agent-common') }
  end

  context 'when manufacturer => Foo' do
    let(:facts) do 
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.5',
        :manufacturer           => 'Foo',
      }
    end

    it { should_not contain_class('epel') }
    it { should have_package_resource_count(0) }
    it { should have_service_resource_count(0) }
  end

  # Test boolean validation
  [
    :manage_qemu_agent,
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param => 'foo' }}
      it { expect { should create_class('ovirt::guest') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
