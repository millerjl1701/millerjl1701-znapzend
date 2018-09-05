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

  $filename = regsubst("${title}",'\/','_','G')

  file { "/etc/znapzend/${filename}":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
  }
}
