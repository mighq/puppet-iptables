class iptables::install {
  include stdlib
  include iptables::params

  if $::os['family'] == 'RedHat' {
    if $::os['release']['major'] == 6 {
      package { 'iptables':
        ensure => 'present',
      }
      ->
      service { 'iptables':
        ensure => running,
        enable => true,
      }
    } elsif $::os['release']['major'] == 7 or $::os['release']['major'] == 8 {
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

  # disable saving state to .save file, conflicts with our functionality
  file_line { 'iptables-config-save-stop':
    ensure => present,
    path   => '/etc/sysconfig/iptables-config',
    line   => 'IPTABLES_SAVE_ON_STOP="no"',
    match  => '^IPTABLES_SAVE_ON_STOP\=',
    before => Service['iptables'],
  }
  file_line { 'iptables-config-save-restart':
    ensure => present,
    path   => '/etc/sysconfig/iptables-config',
    line   => 'IPTABLES_SAVE_ON_RESTART="no"',
    match  => '^IPTABLES_SAVE_ON_RESTART\=',
    before => Service['iptables'],
  }

  # only reload script
  # we rely on standard start and stop script from distribution
  $script_dir = '/usr/local/sbin'
  exec { "ensuredir:${script_dir}":
    command => "/usr/bin/mkdir -p ${script_dir}",
    creates => $script_dir,
  }
  ->
  file { "${script_dir}/${iptables::params::sync_script}":
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/${iptables::params::sync_script}",
  }
}
