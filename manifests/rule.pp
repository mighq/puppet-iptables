define iptables::rule(
  $command,
  $chain,
  $table = 'filter',
) {
  include iptables::params

  datacat_fragment { "${::iptables::params::datacat_structure}/rule/${title}":
    target => $::iptables::params::datacat_structure,
    data   => {
      v4 => {
        "${table}" => {
          "${chain}" => {
            rules => {
              "${command}" => "${title}",
            }
          }
        }
      }
    }
  }
}
