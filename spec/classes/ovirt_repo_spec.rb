require 'spec_helper'

describe 'ovirt::repo' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt::repo') }
  it { should contain_class('ovirt') }
  it { should contain_class('epel') }

  it { should contain_stage('ovirt_repo_clean').that_comes_before('Stage[main]') }
  it { should contain_class('ovirt::repo::clean').with_stage('ovirt_repo_clean') }

  it do
    should contain_file('/etc/pki/rpm-gpg/RPM-GPG-ovirt').with({
      :ensure => 'present',
      :owner  => 'root',
      :group  => 'root',
      :mode   => '0644',
      :source => 'puppet:///modules/ovirt/RPM-GPG-ovirt',
    })
  end

  it do
    should contain_gpg_key('RPM-GPG-ovirt').with({
      :path   => '/etc/pki/rpm-gpg/RPM-GPG-ovirt',
      :before => 'Yumrepo[ovirt-stable]',
    })
  end

  it { should contain_yumrepo('ovirt-stable') }
  it { should contain_yumrepo('ovirt-glusterfs-epel') }
  it { should contain_yumrepo('ovirt-glusterfs-noarch-epel') }
  it { should contain_yumrepo('ovirt-jpackage-6.0-generic') }
end
