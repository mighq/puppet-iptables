define iptables::func::verify_chain_id(
  $policy = undef,
) {
  include iptables::params

  $parts = split($title, ':')
  if $parts == '' or size($parts) < 2 {
    fail("title of chain must contain table reference ('TABLE:CHAIN')")
  }

  $table = $parts[0]
  $chain = $parts[1]

  # verify table name
  if ! has_key($iptables::params::builtins, $table) {
    fail("invalid table '${table}' specified")
  }

  if $policy {
    if ! ($policy in $iptables::params::policies) {
      fail("invalid policy '${policy}'")
    }

    # for builtins also verify chain name
    if ! ($chain in $iptables::params::builtins[$table]) {
      fail("chain '${chain}' in table '${table}' is not builtin, cannot set the policy")
    }
  }

  if ($chain in $iptables::params::builtins[$table]) and ! $policy {
    fail("you must specify policy for builtin chain '${chain}'")
  }
}
