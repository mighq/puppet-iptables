define iptables::chain::builtin(
  $policy,
  $rules = [],
  $comment = undef,
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

  datacat_fragment { "fw/v4/chain/builtin/${title}":
    target => 'firewall_ipv4',
    data   => {
      v4 => {
        "${table}" => {
          "${chain}" => {
            policy => $policy
          }
        }
      }
    }
  }

  iptables::chain::immutable { $title:
    rules   => $rules,
    comment => $comment,
  }
}
