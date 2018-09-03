# @api private
#
# This class is meant to be called from znapzend to manage the znapzend service.
#
class znapzend::service {
  assert_private('znapzend::service is a private class')

  #service { $::znapzend::service_name:
  #  ensure     => $::znapzend::service_ensure,
  #  enable     => $::znapzend::service_enable,
  #  hasstatus  => true,
  #  hasrestart => true,
  #}
}
