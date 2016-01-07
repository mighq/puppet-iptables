define iptables::chain::open(
  $comment = '',
) {
  $parts = split($title, ':')
  if $parts == '' or size($parts) < 2 {
    fail("title of chain must contain table reference ('TABLE:CHAIN')")
  }

  $table = $parts[0]
  $chain = $parts[1]

  datacat_fragment { "fw/v4/chain/open/${title}":
    target => 'firewall_ipv4',
    data   => {
      v4 => {
        "${table}" => {
          "${chain}" => {
            type    => 'open',
            rules   => {},
            comment => $comment,
            defined => true,
          }
        }
      }
    }
  }
}
