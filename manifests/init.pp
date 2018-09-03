# Class: znapzend
# ===========================
#
# Main class that includes all other classes for the znapzend module.
#
# @param package_ensure Whether to install the znapzend package, and/or what version. Values: 'present', 'latest', or a specific version number. Default value: present.
# @param package_name Specifies the name of the package to install. Default value: 'znapzend'.
# @param service_enable Whether to enable the znapzend service at boot. Default value: true.
# @param service_ensure Whether the znapzend service should be running. Default value: 'running'.
# @param service_name Specifies the name of the service to manage. Default value: 'znapzend'.
#
class znapzend (
  String                     $package_ensure = 'present',
  String                     $package_name   = 'znapzend',
  Boolean                    $service_enable = true,
  Enum['running', 'stopped'] $service_ensure = 'running',
  String                     $service_name   = 'znapzend',
  ) {
  case $::operatingsystem {
    'RedHat', 'CentOS': {
      contain znapzend::install
      contain znapzend::config
      contain znapzend::service

      Class['znapzend::install']
      -> Class['znapzend::config']
      ~> Class['znapzend::service']
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
