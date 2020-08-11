define iptables::chain::unmanaged(
  $comment = '',
) {
  include iptables::params

  $parts = split($title, ':')
  if $parts == '' or size($parts) < 2 {
    fail("title of chain must contain table reference ('TABLE:CHAIN')")
  }

  $table = $parts[0]
  $chain = $parts[1]

  if $chain !~ /^\/.*\/$/ {
    datacat_fragment { "${::iptables::params::datacat_structure}/chain/unmanaged/${title}":
      target => $::iptables::params::datacat_structure,
      data   => {
        v4 => {
          "${table}" => {
            "${chain}" => {
              type    => 'unmanaged',
              rules   => {},
              comment => $comment,
              defined => true,
            }
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
