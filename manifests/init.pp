class iptables() {
  include iptables::params

  # install binaries for doing the changes on the server
  include iptables::install

  # just shortcut to ::params variable
  $definition_file = $iptables::params::definition_file

  # manage definition file content by datacat & erb template
  datacat_collector { $::iptables::params::datacat_structure:
    template        => 'iptables/dump_v4.erb',
    template_body   => template_body('iptables/dump_v4.erb'),
    target_resource => File["${definition_file}.candidate"],
    target_field    => 'content',
  }
  ->
  file { "${definition_file}.candidate":
    ensure => present,
  }
  datacat_fragment { "${::iptables::params::datacat_structure}/init":
    target => $::iptables::params::datacat_structure,
    data   => {
      v4 => {}
    }
  }

  # manage list of unmanaged chains
  datacat_collector { $iptables::params::datacat_umc:
    template        => 'iptables/unmanaged_chains.erb',
    template_body   => template_body('iptables/unmanaged_chains.erb'),
    #
    target_resource => File["${definition_file}.umc"],
    target_field    => 'content',
  }
  ->
  file { "${definition_file}.umc":
    ensure => present,
  }
  datacat_fragment { "${::iptables::params::datacat_umc}/init":
    target => $::iptables::params::datacat_umc,
    data   => {
      v4 => {}
    }
  }

  # command for loading the firewall definition into kernel runtime
  exec { 'apply iptables definition':
    command => "/usr/local/sbin/${iptables::params::sync_script} -c ${definition_file}.candidate -d ${definition_file} -u ${definition_file}.umc",

    # run if candidate (managed) and the validate file are out of sync
    unless  => "cmp ${definition_file} ${definition_file}.candidate",
    path    => ['/bin', '/usr/bin'],
  }

  File["${definition_file}.umc"]                           -> Exec['apply iptables definition']

  # also update, if candidate was updated
  File["${definition_file}.candidate"]                     ~> Exec['apply iptables definition']

  # also update, if script was updated
  File["/usr/local/sbin/${iptables::params::sync_script}"] ~> Exec['apply iptables definition']
}
