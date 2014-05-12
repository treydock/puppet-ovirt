require 'spec_helper'

describe 'ovirt' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt') }
  it { should contain_class('ovirt::params') }
  it { should contain_class('epel') }

  it do
    should contain_package('ovirt-release').only_with({
      'ensure'    => 'installed',
      'name'      => 'ovirt-release34',
      'source'    => 'http://resources.ovirt.org/pub/yum-repo/ovirt-release34.rpm',
      'require'   => 'Yumrepo[epel]',
      'provider'  => 'rpm',
    })
  end

  context 'when operatingsystem => "Fedora"' do
    let(:facts) { default_facts.merge({ :operatingsystem => "Fedora" }) }
    it { should contain_package('ovirt-release').with_source('http://resources.ovirt.org/pub/yum-repo/ovirt-release34.rpm') }
  end

  context "when release_version => '33'" do
    let(:params) {{ :release_version => '33' }}
    it { expect { should create_class('ovirt') }.to raise_error(Puppet::Error, /Only release_version 34 is supported/) }
  end
end
