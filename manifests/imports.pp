# Class znapzend::imports
# ===========================
#
# Class for collecting and created znapzend backup plans to import onto datasets. Data is either passed via the imports plans parameter or via hiera.
#
# @summary Class for collecting and created znapzend backup plans to import onto datasets. Data is either passed via the imports plans parameter or via hiera.
#
# @example hiera file providing data
#
# @param plans Hash of plans for which each will result in creation of a config file which is then imported into the properties of the zfs file system for use by znapzend. The title of each plan needs to be the zfs file system name in the form of poolname/filesystem/filesystem.
#
class znapzend::imports (
  Hash $plans = {},
) {
  include ::znapzend

  if length($plans) {
    $plans.each |String $key, Hash $options| {
      znapzend::import { $key:
        options =>  $options,
      }
    }
  }
}
