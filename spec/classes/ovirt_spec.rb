require 'spec_helper'

describe 'ovirt' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt') }
  it { should contain_class('ovirt::params') }
  it { should contain_class('epel') }

  it do
    should contain_yumrepo('glusterfs').with({
      'name'      => 'glusterfs-epel',
      'baseurl'   => 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-$releasever/$basearch/',
      'descr'     => 'GlusterFS is a clustered file-system capable of scaling to several petabytes.',
      'enabled'   => '1',
      'gpgcheck'  => '0',
      'require'   => 'Yumrepo[epel]',
    })
  end

  it { should contain_yumrepo('glusterfs').that_comes_before('Yumrepo[glusterfs-noarch]') }

  it do
    should contain_yumrepo('glusterfs-noarch').with({
      'name'      => 'glusterfs-noarch-epel',
      'baseurl'   => 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-$releasever/noarch',
      'descr'     => 'GlusterFS is a clustered file-system capable of scaling to several petabytes.',
      'enabled'   => '1',
      'gpgcheck'  => '0',
      'before'    => 'Yumrepo[ovirt-stable]',
    })
  end

  it { should contain_yumrepo('glusterfs-noarch').that_comes_before('Yumrepo[ovirt-stable]') }

  it do
    should contain_yumrepo('ovirt-stable').with({
      'baseurl'   => 'http://ovirt.org/releases/stable/rpm/EL/$releasever/',
      'descr'     => 'Older Stable builds of the oVirt project',
      'enabled'   => '1',
      'gpgcheck'  => '0',
    })
  end

  it { should contain_yumrepo('ovirt-stable').that_comes_before('Yumrepo[ovirt-release]') }

  it do
    should contain_yumrepo('ovirt-release').with({
      'name'      => 'ovirt-3.3.3',
      'baseurl'   => 'http://resources.ovirt.org/releases/3.3.3/rpm/EL/$releasever/',
      'descr'     => 'oVirt 3.3.3 release',
      'enabled'   => '1',
      'gpgcheck'  => '0',
    })
  end

  context 'when ovirt_stable_repo_baseurl => "foo"' do
    let(:params) {{ :ovirt_stable_repo_baseurl => "foo" }}
    it { should contain_yumrepo('ovirt-stable').with_baseurl('foo') }
  end

  context 'when ovirt_release_repo_baseurl => "bar"' do
    let(:params) {{ :ovirt_release_repo_baseurl => "bar" }}
    it { should contain_yumrepo('ovirt-release').with_baseurl('bar') }
  end

  context 'when operatingsystem => "Fedora"' do
    let(:facts) { default_facts.merge({ :operatingsystem => "Fedora" }) }
    it { should contain_yumrepo('glusterfs').with_name('glusterfs-fedora') }
    it { should contain_yumrepo('glusterfs').with_baseurl('http://download.gluster.org/pub/gluster/glusterfs/LATEST/Fedora/fedora-$releasever/$basearch/') }
    it { should contain_yumrepo('glusterfs-noarch').with_name('glusterfs-noarch-fedora') }
    it { should contain_yumrepo('glusterfs-noarch').with_baseurl('http://download.gluster.org/pub/gluster/glusterfs/LATEST/Fedora/fedora-$releasever/noarch/') }
    it { should contain_yumrepo('ovirt-stable').with_baseurl('http://ovirt.org/releases/stable/rpm/Fedora/$releasever/') }
    it { should contain_yumrepo('ovirt-release').with_baseurl('http://resources.ovirt.org/releases/3.3.3/rpm/Fedora/$releasever/') }
  end

  context 'when release_version => "3.3.2"' do
    let(:params) {{ :release_version => "3.3.2" }}
    it do
      should contain_yumrepo('ovirt-release').with({
        'name'      => 'ovirt-3.3.2',
        'baseurl'   => 'http://resources.ovirt.org/releases/3.3.2/rpm/EL/$releasever/',
        'descr'     => 'oVirt 3.3.2 release',
        'enabled'   => '1',
        'gpgcheck'  => '0',
      })
    end
  end
end
