define iptables::chain::builtin(
  $policy  = 'ACCEPT',
  $jumps   = [],
  $comment = '',
) {
  include iptables::params

  $parts = split($title, ':')
  if $parts == '' or size($parts) < 2 {
    fail("title of chain must contain table reference ('TABLE:CHAIN')")
  }

  $table = $parts[0]
  $chain = $parts[1]

  if ! has_key($iptables::params::builtins, $table) {
    fail("invalid table '${table}' specified")
  }

  if ! ($chain in $iptables::params::builtins[$table]) {
    fail("invalid chain '${chain}' in table '${table}'")
  }

  if ! ($policy in $iptables::params::targets) {
    fail("invalid policy '${policy}'")
  }

  datacat_fragment { "${::iptables::params::datacat_structure}/chain/builtin/${title}":
    target => $::iptables::params::datacat_structure,
    data   => {
      v4 => {
        "${table}" => {
          "${chain}" => {
            defined => true,
            type    => 'builtin',
            policy  => $policy,
            jumps   => $jumps,
            comment => $comment,
          }
        }
      }
    }
  }
}
