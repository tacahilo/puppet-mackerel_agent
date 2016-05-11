# == Class: mackerel_agent::install
#
class mackerel_agent::install(
  $ensure              = present,
  $use_metrics_plugins = undef,
  $use_check_plugins   = undef
) {
  $gpgkey_url = 'https://mackerel.io/assets/files/GPG-KEY-mackerel'

  case $::osfamily {
    'RedHat': {
      yumrepo { 'mackerel':
        name     => 'mackerel',
        baseurl  => "http://yum.mackerel.io/centos/${::architecture}",
        descr    => 'mackerel-agent',
        enabled  => 1,
        gpgkey   => $gpgkey_url,
        gpgcheck => 1,
        before   => Package['mackerel-agent']
      }
    }
    'Debian': {
      apt::key { 'mackerel':
        id     => '2748FD61027D357542F8394DF92F673FC2B48821',
        source => $gpgkey_url
      }

      apt::source { 'mackerel':
        location => 'http://apt.mackerel.io/debian/',
        release  => 'mackerel',
        repos    => 'contrib',
        include  => {
          source => false
        },
        require  => Apt::Key['mackerel'],
        before   => Package['mackerel-agent']
      }
    }
    default: {
      # Do nothing
    }
  }

  package { 'mackerel-agent':
    ensure => $ensure
  }

  case $use_metrics_plugins {
    true: {
      package { 'mackerel-agent-plugins':
        ensure  => present,
        require => Yumrepo['mackerel'],
      }
    }
    false: {
      package { 'mackerel-agent-plugins':
        ensure  => absent,
        require => Yumrepo['mackerel'],
      }
    }
    'latest': {
      package { 'mackerel-agent-plugins':
        ensure  => latest,
        require => Yumrepo['mackerel'],
      }
    }
    default: {
      # Do nothing
    }
  }

  case $use_check_plugins {
    true: {
      package { 'mackerel-check-plugins':
        ensure  => present,
        require => Yumrepo['mackerel'],
      }
    }
    false: {
      package { 'mackerel-check-plugins':
        ensure  => absent,
        require => Yumrepo['mackerel'],
      }
    }
    'latest': {
      package { 'mackerel-check-plugins':
        ensure  => latest,
        require => Yumrepo['mackerel'],
      }
    }
    default: {
      # Do nothing
    }
  }
}
