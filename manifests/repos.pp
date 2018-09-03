# @api private
#
# This class is called from the main znapzend class for adding needed repos.
#
class znapzend::repos {
  assert_private('znapzend::repos is a private class')

  if $znapzend::manage_epel {
    include epel
  }
}
