define iptables::rule(
  $command,
  $chain,
  $table = 'filter',
) {
  datacat_fragment { "fw/rule/v4/${title}":
    target => 'firewall_ipv4',
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
