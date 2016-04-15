class iptables() {
  datacat_collector { 'firewall_ipv4':
    template        => 'iptables/dump_v4.erb',
    template_body   => template_body('iptables/dump_v4.erb'),
    target_resource => File['/etc/sysconfig/iptables'],
    target_field    => 'content',
  }
  ->
  package { 'iptables':
    ensure => present,
  }
  ->
  file { '/etc/sysconfig/iptables':
    ensure => present,
  }
  ->
  service { 'iptables':
    ensure => running,
    enable => true,
  }

  File['/etc/sysconfig/iptables']
  ~>
  exec { 'apply iptables definition':
    command     => '/sbin/iptables-restore < /etc/sysconfig/iptables',
    refreshonly => true,
  }
}
