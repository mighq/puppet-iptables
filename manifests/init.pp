class iptables() {
  datacat_collector { 'firewall_ipv4':
    template        => 'iptables/dump_v4.erb',
    template_body   => template_body('iptables/dump_v4.erb'),
    target_resource => File['/etc/sysconfig/iptables'],
    target_field    => 'content',
  }
  ->
  file { '/etc/sysconfig/iptables':
    ensure  => present,
  }
  ~>
  exec { 'apply iptables definition':
    command     => '/sbin/iptables-restore < /etc/sysconfig/iptables',
    refreshonly => true,
  }
}
