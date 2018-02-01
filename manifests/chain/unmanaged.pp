# TODO: regex for name of the chain
define iptables::chain::unmanaged(
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

  datacat_fragment { "${::iptables::params::datacat_structure}/chain/unmanaged/${title}":
    target => $::iptables::params::datacat_structure,
    data   => {
      v4 => {
        "${table}" => {
          "${chain}" => {
            type    => 'unmanaged',
            rules   => {},
            comment => $comment,
            policy  => $policy,
            defined => true,
          }
        }
      }
    }
  }

  datacat_fragment { "${::iptables::params::datacat_umc}/${title}":
    target => $::iptables::params::datacat_umc,
    data   => {
      v4 => {
        "${table}" => {
          "${chain}" => true,
        }
      }
    }
  }

}
