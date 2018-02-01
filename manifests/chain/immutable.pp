define iptables::chain::immutable(
  $comment = '',
  $rules  = undef,
  $jumps  = undef,
  $policy = undef,
) {
  iptables::func::verify_chain_id { $title:
    policy => $policy,
  }

  if (!$rules and !$jumps) or ($rules and $jumps) {
    fail("specify one of \$rules or \$jumps parameter, but not both")
  }
  if $rules and !is_array($rules) {
    fail("\$rules parameter must be an array")
  }
  if $jumps and !is_array($jumps) {
    fail("\$jumps parameter must be an array")
  }

  $parts = split($title, ':')
  $table = $parts[0]
  $chain = $parts[1]

  include iptables::params

  datacat_fragment { "${::iptables::params::datacat_structure}/chain/immutable/${title}":
    target => $::iptables::params::datacat_structure,
    data   => {
      v4 => {
        "${table}" => {
          "${chain}" => {
            type    => 'immutable',
            irules  => $rules,
            jumps   => $jumps,
            comment => $comment,
            policy  => $policy,
            defined => true,
          }
        }
      }
    }
  }
}
