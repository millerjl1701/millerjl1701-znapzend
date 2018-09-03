# @api private
#
# This class is called from the main znapzend class for installing prerequisites.
#
class znapzend::prereqs {
  assert_private('znapzend::prereqs is a private class')

  if $znapzend::manage_prereqs {
    if $znapzend::manage_gcc {
      package { $znapzend::gcc_packages:
        ensure => present,
      }
    }
    if $znapzend::manage_mbuffer {
      package { $znapzend::mbuffer_packages:
        ensure => present,
      }
    }
    if $znapzend::manage_perl {
      package { $znapzend::perl_packages:
        ensure => present,
      }
    }
  }
}
