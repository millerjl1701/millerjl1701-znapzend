# Define znapzend::import
# ===========================
#
# Defined type for a backup plan for a  zfs dataset to be imported by znapzendzetup.
#
# @param
#
define znapzend::import (
  Hash              $options,
) {
  include ::znapzend

  $filename = regsubst("${pool}/${filesystem}",'\/','_','G')

  file { "/root/znapzend_configs/${filename}.conf":
    ensure  => 'present',
    mode    => '600',
    owner   => '0',
    group   => '0',
    content => template('znapzend/znapzend-template.erb'),
  }
  exec { "znapzend_import_${filename}":
    path =>  ["/usr/bin", "/bin", "/sbin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin", "/opt/znapzend/bin"],
    command =>  "/bin/cat /root/znapzend_configs/${filename}.conf | znapzendzetup import --write ${pool}/${filesystem}",
    subscribe =>  [ File["/root/znapzend_configs/${filename}.conf"], Zfs["${pool}/${filesystem}"] ],
    refreshonly =>  true,
    onlyif =>  "/bin/test -e /${pool}/${filesystem}",
    notify =>  Service['znapzend']
  }
}
