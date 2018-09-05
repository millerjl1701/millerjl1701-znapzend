# @api private
#
# This class is called from the main znapzend class for install.
#
class znapzend::install {
  assert_private('znapzend::install is a private class')

  file { $znapzend::znapzend_package_extractpath:
    ensure => directory,
  }
  archive { "znapzend-${znapzend::znapzend_package_version}.tar.gz":
    path         => "${znapzend::znapzend_download_location}/znapzend-${znapzend::znapzend_package_version}.tar.gz",
    provider     =>  'wget',
    source       => $znapzend::znapzend_package_url,
    extract      => true,
    extract_path => $znapzend::znapzend_package_extractpath,
    creates      => "${znapzend::znapzend_package_extractpath}/znapzend-${znapzend::znapzend_package_version}",
    cleanup      => true,
    require      => File[$znapzend::znapzend_package_extractpath],
  }
  exec { 'znapzend_source_configure':
    command => "./configure --prefix=${znapzend::znapzend_install_prefix}",
    cwd     => "${znapzend::znapzend_package_extractpath}/znapzend-${znapzend::znapzend_package_version}",
    path    => [ "${znapzend::znapzend_package_extractpath}/znapzend-${znapzend::znapzend_package_version}", '/bin', '/usr/bin', ],
    creates => "${znapzend::znapzend_package_extractpath}/znapzend-${znapzend::znapzend_package_version}/config.status",
    require => Archive["znapzend-${znapzend::znapzend_package_version}.tar.gz"],
  }
  exec { 'znapzend_make_and_install':
    command => 'make && make install',
    cwd     => "${znapzend::znapzend_package_extractpath}/znapzend-${znapzend::znapzend_package_version}",
    path    => [ '/bin', '/usr/bin', ],
    creates => "${znapzend::znapzend_install_prefix}/bin/znapzend",
    require => Exec['znapzend_source_configure'],
  }
  $znapzend::znapzend_installed_binaries.each |String $binary| {
    file { "${znapzend::znapzend_linkpath}/${binary}":
      ensure  => link,
      target  => "${znapzend::znapzend_install_prefix}/bin/${binary}",
      require => Exec['znapzend_make_and_install'],
    }
  }
}
