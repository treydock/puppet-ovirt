# == Class: ovirt::repo::clean
#
# Private class
#
class ovirt::repo::clean {

  include ::ovirt

  if $::ovirt::version != '3.5' {
    file { "/etc/yum.repos.d/ovirt-${::ovirt::version}.repo": ensure => absent }
  }

  file { "/etc/yum.repos.d/ovirt-${::ovirt::version}-dependencies.repo": ensure => absent }

}
