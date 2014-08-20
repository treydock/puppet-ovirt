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
  $release_version            = '34',
  $version                    = '3.4',
  $ovirt_release_url          = $ovirt::params::ovirt_release_url
) inherits ovirt::params {

  validate_re($release_version, [ '^34$' ], 'Only release_version 34 is supported')
  validate_re($version, [ '^3.4$' ], 'Only version 3.4 is supported')

}
