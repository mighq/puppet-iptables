define iptables::chain::open(
  $comment = '',
) {
  include iptables::params

  $parts = split($title, ':')
  if $parts == '' or size($parts) < 2 {
    fail("title of chain must contain table reference ('TABLE:CHAIN')")
  }

  $table = $parts[0]
  $chain = $parts[1]

  datacat_fragment { "${::iptables::params::datacat_structure}/chain/open/${title}":
    target => $::iptables::params::datacat_structure,
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
