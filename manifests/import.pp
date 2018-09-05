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

}
