# Class: znapzend
# ===========================
#
# Main class that includes all other classes for the znapzend module.
#
# @summary Main class for managing the installation and configuration of the znapzend service.
#
# @param gcc_packages Specifies what packages are installed for the build requirements of znapzend for providing gcc/make.
# @param manage_epel Specifies whether or not the module should manage the EPEL repository.
# @param manage_gcc Specifies whether or not the module should manage the installation of gcc.
# @param manage_mbuffer Specifies whether or not the module should manage the installation of mbuffer.
# @param manage_perl Specifies whether on not the module should manage the installation of the perl-core rpm.
# @param manage_prereqs Specifies whether or not the module should manage any of the components of the preqrequites for building znapzend.
# @param mbuffer_packages Specifies what package(s) should be installed on the system to provide mbuffer support for znapzend to use.
# @param perl_packages Specifies what perl RPM(s) should be installed on the system for building and running znapzend.
# @param plan_confdir Specifies where the znapzend backup plan configuration files will be located.
# @param plan_confdir_purge Specifies whether or not the znapzend configuration directories should be purged of files not managed by puppet.
# @param plan_confdir_setup An array of directories that puppet should create on the system for where the znapzend backup plans will be stored.
# @param plan_conffile_mode The mode that should be used for the znapzend backup plan configuration files.
# @param plan_conffile_template The name of the template to use for the znapzend backup plan configuration files.
# @param service_enable Whether to enable the znapzend service at boot.
# @param service_ensure Whether the znapzend service should be running.
# @param service_name Specifies the name of the service to manage.
# @param service_options Specifies options placed in /etc/default/znapzend for use by the znapzend service.
# @param service_options_template Specifies the name of the template to use for /etc/default/znapzend.
# @param service_systemd_afters Specifes what systemd services should be started up prior to the znapzend.service.
# @param service_systemd_template Specifies the name of the template to use for the /etc/systemd/system/znapzend.service file.
# @param service_sysv_template Specifies the name of the template to use for the /etc/init.d/znapzend file.
# @param znapzend_download_location Specifies where the znapzend archive resource should download the tar.gz file to for later extraction.
# @param znapzend_package_version Specifies the version of znapzend to download and install.
# @param znapzend_package_extractpath Specifies where the znapzend archive resource should extract the tar.gz file to for building
# @param znapzend_package_url Specifies the URL of where to download the znapzend tar.gz file. By default, this uses the znapzend_package_version version.
# @param znapzend_install_prefix Specifies the directory to which znapzend should be installed.
# @param znapzend_installed_binaries Specifies a list of znapzend programs to link.
# @param znapzend_linkpath Specifies where the znapzend program links should be created.
#
class znapzend (
  Array                      $gcc_packages                 = [ 'gcc', 'gcc-c++', ],
  Boolean                    $manage_epel                  = true,
  Boolean                    $manage_gcc                   = true,
  Boolean                    $manage_mbuffer               = true,
  Boolean                    $manage_perl                  = true,
  Boolean                    $manage_prereqs               = true,
  Array                      $mbuffer_packages             = [ 'mbuffer', ],
  Array                      $perl_packages                = [ 'perl-core', ],
  Stdlib::Unixpath           $plan_confdir                 = '/etc/znapzend/configs',
  Boolean                    $plan_confdir_purge           = true,
  Array[Stdlib::Unixpath]    $plan_confdir_setup           = [ '/etc/znapzend', '/etc/znapzend/configs', ],
  String                     $plan_conffile_mode           = '0644',
  String                     $plan_conffile_template       = 'znapzend/plan_conffile_template.erb',
  Boolean                    $service_enable               = true,
  Enum['running', 'stopped'] $service_ensure               = 'running',
  String                     $service_name                 = 'znapzend',
  String                     $service_options              = '',
  String                     $service_options_template     = 'znapzend/znapzend.default.erb',
  Array                      $service_systemd_afters       = [ 'zfs-import-cache.service', 'zfs-import-scan.service', ],
  String                     $service_systemd_template     = 'znapzend/znapzend.service.erb',
  String                     $service_sysv_template        = 'znapzend/znapzend.sysv.erb',
  Stdlib::Unixpath           $znapzend_download_location   = '/tmp',
  String                     $znapzend_package_version     = '0.19.1',
  Stdlib::Unixpath           $znapzend_package_extractpath = '/usr/local/src',
  Stdlib::Httpurl            $znapzend_package_url         = "https://github.com/oetiker/znapzend/releases/download/v${znapzend_package_version}/znapzend-${znapzend_package_version}.tar.gz",
  Stdlib::Unixpath           $znapzend_install_prefix      = "/opt/znapzend-${znapzend_package_version}",
  Array                      $znapzend_installed_binaries  = [ 'znapzend', 'znapzendzetup', 'znapzendztatz', ],
  Stdlib::Unixpath           $znapzend_linkpath            = '/usr/local/bin',
  ) {
  case $::osfamily {
    'RedHat': {
      case $::operatingsystemmajrelease {
        '6', '7', '8': {
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
