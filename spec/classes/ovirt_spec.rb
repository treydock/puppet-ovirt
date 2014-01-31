require 'spec_helper'

describe 'ovirt' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt') }
  it { should contain_class('ovirt::params') }
  it { should contain_class('epel') }

  it do
    should contain_yumrepo('glusterfs-epel').with({
      'baseurl'   => 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-$releasever/$basearch/',
      'descr'     => 'GlusterFS is a clustered file-system capable of scaling to several petabytes.',
      'enabled'   => '1',
      'gpgcheck'  => '0',
      'require'   => 'Yumrepo[epel]',
      'before'    => 'Yumrepo[glusterfs-noarch-epel]',
    })
  end

  it { should contain_yumrepo('glusterfs-epel').that_comes_before('Yumrepo[glusterfs-noarch-epel]') }

  it do
    should contain_yumrepo('glusterfs-noarch-epel').with({
      'baseurl'   => 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-$releasever/noarch',
      'descr'     => 'GlusterFS is a clustered file-system capable of scaling to several petabytes.',
      'enabled'   => '1',
      'gpgcheck'  => '0',
      'before'    => 'Yumrepo[ovirt-stable]',
    })
  end

  it { should contain_yumrepo('glusterfs-noarch-epel').that_comes_before('Yumrepo[ovirt-stable]') }

  it do
    should contain_yumrepo('ovirt-stable').with({
      'baseurl'   => 'http://ovirt.org/releases/stable/rpm/EL/$releasever/',
      'descr'     => 'Older Stable builds of the oVirt project',
      'enabled'   => '1',
      'gpgcheck'  => '0',
    })
  end

  context 'when ovirt_release_base_url => "foo"' do
    let(:params) {{ :ovirt_repo_baseurl => "foo" }}
    it { should contain_yumrepo('ovirt-stable').with_baseurl('foo') }
  end
end
