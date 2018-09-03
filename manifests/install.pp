# @api private
#
# This class is called from the main znapzend class for install.
#
class znapzend::install {
  assert_private('znapzend::install is a private class')

  package { $::znapzend::package_name:
    ensure => $::znapzend::package_ensure,
  }
}
