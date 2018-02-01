# TODO:  don't manage regex (consider)
define iptables::chain::open(
  $comment = '',
  $policy  = undef,
) {
  iptables::func::verify_chain_id { $title:
    policy => $policy,
  }

  $parts = split($title, ':')
  $table = $parts[0]
  $chain = $parts[1]

  include iptables::params

  datacat_fragment { "${::iptables::params::datacat_structure}/chain/open/${title}":
    target => $::iptables::params::datacat_structure,
    data   => {
      v4 => {
        "${table}" => {
          "${chain}" => {
            type    => 'open',
            rules   => {},
            comment => $comment,
            policy  => $policy,
            defined => true,
          }
        }
      }
    }
  }
}
