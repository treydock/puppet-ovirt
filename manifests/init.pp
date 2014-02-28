# == Class: ovirt
#
# This class contains the common requirements of ovirt::engine and ovirt::node.
#
# === Parameters
#
# [*ovirt_repo_baseurl*]
#   The baseurl for the ovirt repo.
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2014 Trey Dockendorf
#
class ovirt (
  $release_ensure             = 'installed',
  $ovirt_release_url          = $ovirt::params::ovirt_release_url
) inherits ovirt::params {

  include epel

  package { 'ovirt-release':
    ensure    => $release_ensure,
    source    => $ovirt_release_url,
    require   => Yumrepo['epel'],
    provider  => rpm,
  }
}
