define iptables::chain::immutable(
  $rules,
  $comment = '',
) {
  include iptables::params

  $parts = split($title, ':')
  if $parts == '' or size($parts) < 2 {
    fail("title of chain must contain table reference ('TABLE:CHAIN')")
  }

  $table = $parts[0]
  $chain = $parts[1]

  datacat_fragment { "${::iptables::params::datacat_structure}/chain/immutable/${title}":
    target => $::iptables::params::datacat_structure,
    data   => {
      v4 => {
        "${table}" => {
          "${chain}" => {
            type          => 'immutable',
            rules_final   => $rules,
            comment       => $comment,
            defined       => true,
          }
        }
      }
    }
  }
}
