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
  $version = $ovirt::params::version,
) inherits ovirt::params {

  validate_re($version, [ '^3.4$' ], 'Only version 3.4 is supported')

}
