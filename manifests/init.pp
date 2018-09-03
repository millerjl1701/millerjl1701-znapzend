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
  Array                      $gcc_packages     = [ 'gcc', 'gcc-c++', ],
  Boolean                    $manage_epel      = true,
  Boolean                    $manage_gcc       = true,
  Boolean                    $manage_mbuffer   = true,
  Boolean                    $manage_perl      = true,
  Boolean                    $manage_prereqs   = true,
  Array                      $mbuffer_packages = [ 'mbuffer', ],
  Array                      $perl_packages    = [ 'perl-core', ],
  Boolean                    $service_enable   = true,
  Enum['running', 'stopped'] $service_ensure   = 'running',
  String                     $service_name     = 'znapzend',
  ) {
  case $::osfamily {
    'RedHat': {
      case $::operatingsystemmajrelease {
        '6', '7': {
          contain znapzend::repos
          contain znapzend::prereqs
          contain znapzend::install
          contain znapzend::config
          contain znapzend::service

          Class['znapzend::repos']
          -> Class['znapzend::prereqs']
          -> Class['znapzend::install']
          -> Class['znapzend::config']
          ~> Class['znapzend::service']
        }
        default: {
          fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
        }
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
