# Define znapzend::import
# ===========================
#
# Defined type for a backup plan for a  zfs dataset to be imported by znapzendzetup. Note: the title of the defined type should match the zfs file system name not the mountpoint.
#
# @param options A hash of znapzend options to be imported into the file system.
#
define znapzend::import (
  Hash              $options,
) {
  include ::znapzend

  $filesystem = $title
  $filename = regsubst($title,'\/','_','G')

  file { "${znapzend::plan_confdir}/${filename}.conf":
    ensure  => 'present',
    mode    => $znapzend::plan_conffile_mode,
    owner   => 'root',
    group   => 'root',
    content => template('znapzend/plan_conffile_template.erb'),
    require => File[$znapzend::plan_confdir],
  }
  exec { "znapzend_import_${filename}":
    path        => ['/usr/bin', '/bin', '/sbin', '/usr/sbin', '/usr/local/bin', '/usr/local/sbin', ],
    command     => "cat ${znapzend::plan_confdir}/${filename}.conf | znapzendzetup import --write ${filesystem}",
    subscribe   => File["${znapzend::plan_confdir}/${filename}.conf"],
    refreshonly => true,
    onlyif      => "test -e /${filesystem}",
    notify      => Service[$znapzend::service_name],
  }
}
