# == Class: ovirt::repo
#
# This class contains the Yumrepo resources for oVirt.
#
class ovirt::repo {

  include ::ovirt
  include ::epel

  if versioncmp($::puppetversion, '3.5.0') >= 0 {
    # Yumrepo ensure => absent only in Puppet >= 3.5.0
    yumrepo { "ovirt-${::ovirt::version}-epel": ensure => 'absent' }
  }

  stage { 'ovirt_repo_clean':
    before  => Stage['main'],
  }

  class { 'ovirt::repo::clean':
    stage => ovirt_repo_clean,
  }

  file { '/etc/pki/rpm-gpg/RPM-GPG-ovirt':
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/ovirt/RPM-GPG-ovirt',
  }

  gpg_key { 'RPM-GPG-ovirt':
    path    => '/etc/pki/rpm-gpg/RPM-GPG-ovirt',
    before  => Yumrepo['ovirt-stable'],
  }

  yumrepo { 'ovirt-glusterfs-epel':
    ensure              => 'present',
    name                => "ovirt-${::ovirt::version}-glusterfs-epel",
    baseurl             => 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-$releasever/$basearch/',
    descr               => 'GlusterFS is a clustered file-system capable of scaling to several petabytes.',
    enabled             => '1',
    gpgcheck            => '0',
    skip_if_unavailable => '1',
  }

  yumrepo { 'ovirt-glusterfs-noarch-epel':
    ensure              => 'present',
    name                => "ovirt-${::ovirt::version}-glusterfs-noarch-epel",
    baseurl             => 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-$releasever/noarch',
    descr               => 'GlusterFS is a clustered file-system capable of scaling to several petabytes.',
    enabled             => '1',
    gpgcheck            => '0',
    skip_if_unavailable => '1',
  }

  yumrepo { 'ovirt-jpackage-6.0-generic':
    ensure      => 'present',
    name        => "ovirt-${::ovirt::version}-jpackage-6.0-generic",
    descr       => 'JPackage 6.0, for generic',
    enabled     => '1',
    gpgcheck    => '1',
    gpgkey      => 'http://www.jpackage.org/jpackage.asc',
    includepkgs => 'dom4j,isorelax,jaxen,jdom,msv,msv-xsdlib,relaxngDatatype,servicemix-specs,tomcat5-servlet-2.4-api,ws-jaxme,xalan-j2,xml-commons,xml-commons-jaxp-1.2-apis,xml-commons-resolver11,xom,xpp2,xpp3',
    mirrorlist  => 'http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=6.0',
  }

  yumrepo { 'ovirt-stable':
    ensure              => 'present',
    name                => "ovirt-${::ovirt::version}-stable",
    descr               => "Latest oVirt ${::ovirt::version} Release",
    enabled             => '1',
    gpgcheck            => '1',
    gpgkey              => 'file:///etc/pki/rpm-gpg/RPM-GPG-ovirt',
#    baseurl            => "http://resources.ovirt.org/pub/ovirt-${::ovirt::version}/rpm/el${::operatingsystemmajrelease}/",
    mirrorlist          => "http://resources.ovirt.org/pub/yum-repo/mirrorlist-ovirt-${::ovirt::version}-el${::operatingsystemmajrelease}",
    skip_if_unavailable => '1',
  }

}
