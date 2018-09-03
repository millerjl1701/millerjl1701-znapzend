node default {

  notify { 'enduser-before': }
  notify { 'enduser-after': }

  class { 'znapzend':
    require => Notify['enduser-before'],
    before  => Notify['enduser-after'],
  }

}
