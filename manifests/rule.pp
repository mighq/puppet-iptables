define iptables::rule(
  $table = 'filter',
  $chain,
  $command,
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
