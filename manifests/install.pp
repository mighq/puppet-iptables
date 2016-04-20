class iptables::install {
  include iptables::params

  package { 'iptables':
    ensure => present,
  }
  ->
  service { 'iptables':
    ensure => running,
    enable => true,
  }

  # helper script
  file { "/usr/local/sbin/${iptables::params::sync_script}":
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/${iptables::params::sync_script}",
  }
}
