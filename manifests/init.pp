# class for managing iptables firewall ruleset
#
# Warning:
# * if you don't specify any structure, just include this class
#   script won't do any changes to current firewall\
#   (like running iptables-restore on empty file)
class iptables(
  $fallback_policy = 'restrictive',
  $fallback_iptables_file = 'puppet:///modules/iptables/fallback.ipt',
) {
  include iptables::params

  # install binaries for doing the changes on the server
  include iptables::install

  validate_re($fallback_policy, [ '^restrictive$', '^permissive$' ])

  if      $fallback_policy == 'restrictive' {
    $fallback_policy_arg = '-r'
  } elsif $fallback_policy == 'permissive' {
    $fallback_policy_arg = '-p'
  }

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

  # initial IPv4 data structure
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

  # fallback data
  # even on-boot script from iptables-services (centos/7) package
  # uses this if definition file is not successfully loaded
  file { "${definition_file}.fallback":
    source => $fallback_iptables_file,
  }
  ->
  # validation each puppet run
  # otherwise we would discover broken fallback file only in corner cases like
  # on restart or after failed candidate application
  exec { 'validate iptables.fallback definition':
    command => "bash -c 'exit 1'",
    unless  => "iptables-restore --test ${definition_file}.fallback",
    path    => ['/bin', '/usr/bin', '/sbin' , '/usr/sbin' ],
  }

  # command for loading the firewall definition into kernel runtime for changes done by puppet
  # note: for startup of the service (on boot)
  # /usr/libexec/iptables/iptables.init file from iptables-services package is used (centos/7)
  exec { 'apply iptables definition':
    command => "/usr/local/sbin/${iptables::params::sync_script} -d ${definition_file} -c ${definition_file}.candidate -u ${definition_file}.umc -f ${definition_file}.fallback ${fallback_policy_arg}",

    logoutput => true,

    # run if candidate (managed) and the validated file are out of sync
    unless  => "cmp ${definition_file} ${definition_file}.candidate",
    path    => ['/bin', '/usr/bin', '/sbin' , '/usr/sbin' ],
    timeout => 1800,
  }

  # do not even try running apply, if fallback not valid
  Exec['validate iptables.fallback definition']            -> Exec['apply iptables definition']

  # files apply script needs
  File["${definition_file}.fallback"]                      -> Exec['apply iptables definition']
  File["${definition_file}.umc"]                           -> Exec['apply iptables definition']

  # also update, if candidate was updated
  File["${definition_file}.candidate"]                     ~> Exec['apply iptables definition']
}
