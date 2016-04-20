class iptables() {
  include iptables::params

  # install binaries for doing the changes on the server
  include iptables::install

  # just shortcut to ::params variable
  $definition_file = $iptables::params::definition_file

  # manage definition file content by datacat & erb template
  datacat_collector { 'firewall_ipv4':
    template        => 'iptables/dump_v4.erb',
    template_body   => template_body('iptables/dump_v4.erb'),
    target_resource => File["${definition_file}.candidate"],
    target_field    => 'content',
  }
  ->
  file { "${definition_file}.candidate":
    ensure => present,
  }

  # command for loading the firewall definition into kernel runtime
  exec { 'apply iptables definition':
    command => "/usr/local/sbin/${iptables::params::sync_script} -c ${definition_file}.candidate -d ${definition_file}",

    # run if candidate (managed) and the validate file are out of sync
    unless  => "cmp ${definition_file} ${definition_file}.candidate",
  }

  # also update, if candidate was updated
  File["${definition_file}.candidate"]                     ~> Exec['apply iptables definition']

  # also update, if script was updated
  File["/usr/local/sbin/${iptables::params::sync_script}"] ~> Exec['apply iptables definition']
}
