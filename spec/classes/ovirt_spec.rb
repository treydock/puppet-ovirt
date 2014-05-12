require 'spec_helper'

describe 'ovirt' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt') }
  it { should contain_class('ovirt::params') }
  it { should contain_class('epel') }

  it do
    should contain_package('ovirt-release').with({
      'ensure'    => 'installed',
      'source'    => 'http://resources.ovirt.org/pub/yum-repo/ovirt-release34.rpm',
      'require'   => 'Yumrepo[epel]',
      'provider'  => 'rpm',
    })
  end

  context 'when operatingsystem => "Fedora"' do
    let(:facts) { default_facts.merge({ :operatingsystem => "Fedora" }) }
    it { should contain_package('ovirt-release').with_source('http://resources.ovirt.org/pub/yum-repo/ovirt-release34.rpm') }
  end
end
