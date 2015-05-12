# == Class: ovirt::repo
#
# This class contains the Yumrepo resources for oVirt.
#
class ovirt::repo {

  include ::ovirt
  include ::epel

  case $::ovirt::version {
    '3.4': {
      $jpackage_includepkgs     = 'dom4j,isorelax,jaxen,jdom,msv,msv-xsdlib,relaxngDatatype,servicemix-specs,tomcat5-servlet-2.4-api,ws-jaxme,xalan-j2,xml-commons,xml-commons-jaxp-1.2-apis,xml-commons-resolver11,xom,xpp2,xpp3'
      $manage_patternfly1_repo  = false
      $ovirt_repo_name          = 'ovirt-3.4-stable'
    }
    '3.5': {
      $jpackage_includepkgs     = 'dom4j,isorelax,jaxen,jdom,msv,msv-xsdlib,relaxngDatatype,servicemix-specs,tomcat5-servlet-2.4-api,ws-jaxme,xalan-j2,xml-commons,xml-commons-jaxp-1.2-apis,xml-commons-resolver11,xom,xpp2,xpp3,antlr3,stringtemplate'
      $manage_patternfly1_repo  = true
      $ovirt_repo_name          = 'ovirt-3.5'
    }
    default: {}
  }

  if versioncmp($::puppetversion, '3.5.0') >= 0 {
    # Yumrepo ensure only in Puppet >= 3.5.0
    Yumrepo <| title == 'ovirt-glusterfs-epel' |> { ensure => 'present' }
    Yumrepo <| title == 'ovirt-glusterfs-noarch-epel' |> { ensure => 'present' }
    Yumrepo <| title == 'ovirt-jpackage-6.0-generic' |> { ensure => 'present' }
    Yumrepo <| title == 'ovirt-stable' |> { ensure => 'present' }
    yumrepo { "ovirt-${::ovirt::version}-epel": ensure => 'absent' }
  }

  stage { 'ovirt_repo_clean':
    before  => Stage['main'],
  }

  class { 'ovirt::repo::clean':
    stage => ovirt_repo_clean,
  }

  if $ovirt::manage_gluster_repos {
    yumrepo { 'ovirt-glusterfs-epel':
      name                => "ovirt-${::ovirt::version}-glusterfs-epel",
      baseurl             => 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-$releasever/$basearch/',
      descr               => 'GlusterFS is a clustered file-system capable of scaling to several petabytes.',
      enabled             => '1',
      gpgcheck            => '0',
    }

    yumrepo { 'ovirt-glusterfs-noarch-epel':
      name                => "ovirt-${::ovirt::version}-glusterfs-noarch-epel",
      baseurl             => 'http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-$releasever/noarch',
      descr               => 'GlusterFS is a clustered file-system capable of scaling to several petabytes.',
      enabled             => '1',
      gpgcheck            => '0',
    }
  }

  if $ovirt::manage_jpackage_repo {
    yumrepo { 'ovirt-jpackage-6.0-generic':
      name        => "ovirt-${::ovirt::version}-jpackage-6.0-generic",
      descr       => 'JPackage 6.0, for generic',
      enabled     => '1',
      gpgcheck    => '1',
      gpgkey      => 'http://www.jpackage.org/jpackage.asc',
      includepkgs => $jpackage_includepkgs,
      mirrorlist  => 'http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=6.0',
    }
  }

  if $manage_patternfly1_repo {
    yumrepo { 'ovirt-patternfly1-noarch-epel':
      name     => "ovirt-${::ovirt::version}-patternfly1-noarch-epel",
      descr    => 'Copr repo for patternfly1 owned by patternfly',
      baseurl  => "http://copr-be.cloud.fedoraproject.org/results/patternfly/patternfly1/${ovirt::patternfly1_repo_osbit}/",
      enabled  => '1',
      gpgcheck => '0',
    }

    if versioncmp($::puppetversion, '3.5.0') >= 0 {
      # Yumrepo ensure only in Puppet >= 3.5.0
      Yumrepo <| title == 'ovirt-patternfly1-noarch-epel' |> { ensure => 'present' }
    }

    if versioncmp($::puppetversion, '3.6.0') >= 0 {
      Yumrepo <| title == 'ovirt-patternfly1-noarch-epel' |> {
        skip_if_unavailable => '1',
      }
    }
  }

  yumrepo { 'ovirt-stable':
    name                => $ovirt_repo_name,
    descr               => "Latest oVirt ${::ovirt::version} Release",
    enabled             => '1',
    gpgcheck            => '1',
    gpgkey              => 'http://plain.resources.ovirt.org/pub/keys/RPM-GPG-ovirt',
#    baseurl            => "http://resources.ovirt.org/pub/ovirt-${::ovirt::version}/rpm/el${::operatingsystemmajrelease}/",
    mirrorlist          => "http://resources.ovirt.org/pub/yum-repo/mirrorlist-ovirt-${::ovirt::version}-el${::operatingsystemmajrelease}",
  }

  # Yumrepo skip_if_unavailable only in Puppet >= 3.6.0
  if versioncmp($::puppetversion, '3.6.0') >= 0 {
    Yumrepo <| title == 'ovirt-glusterfs-epel' |> {
      skip_if_unavailable => '1',
    }

    Yumrepo <| title == 'ovirt-glusterfs-noarch-epel' |> {
      skip_if_unavailable => '1',
    }

    Yumrepo <| title == 'ovirt-stable' |> {
      skip_if_unavailable => '1',
    }
  }

}
