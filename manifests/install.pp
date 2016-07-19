class iptables::install {
  include iptables::params

  if $::osfamily == 'RedHat' {
    if      $::operatingsystemmajrelease == 6 {
      package { 'iptables':
        ensure => 'present',
      }
      ->
      service { 'iptables':
        ensure => running,
        enable => true,
      }
    } elsif $::operatingsystemmajrelease == 7 {
      # do not manage firewall the os default way (firewalld)
      if versioncmp($::puppetversion, '4.2') >= 0 {
        service { 'firewalld':
          ensure   => 'stopped',
          enable   => 'mask',
          provider => 'systemd',
        }
      } else {
        service { 'firewalld':
          ensure   => 'stopped',
          enable   => false,
          provider => 'systemd',
        }
        ->
        # make sure firewalld is not started at any time, even through dependencies
        exec { 'mask_firewalld_service':
          command => '/bin/systemctl mask firewalld',
          unless  => "/bin/bash -c '/bin/systemctl show firewalld | /bin/fgrep LoadState=masked'",
        }
      }

      # use iptables instead
      package { ['iptables', 'iptables-services']:
        ensure   => 'present',
      }
      ->
      Service['firewalld']
      ->
      # make them running
      service { 'iptables':
        ensure => running,
        enable => true,
      }
    } else {
      fail('Unsupported RedHat release.')
    }
  } else {
    fail('Unsupported OS.')
  }

  # only reload script
  # we rely on standard start and stop script from distribution
  file { "/usr/local/sbin/${iptables::params::sync_script}":
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/${iptables::params::sync_script}",
  }
}
