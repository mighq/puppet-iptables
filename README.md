# iptables

## Overview

Flexible iptables management by puppet.

Based on concept of "immutable" and "open" chains.

### immutable / builtin

Chain, which is defined at once, on one place in catalogue. The order of rules is fixed. Cannot be changed later in catalogue.

Builtin chains also have default policy attribute, they are like immutable otherwise.

### open

Chain defined without rules in it. Rules can be added from multiple places in catalogue. Order of rules does not matter.

### unmanaged

Chain which is defined to be created and can be referenced, but puppet will ignore its contents. Good for chains, which are managed by some other software (ie. docker).

As an alternative, these chains can be declared in a "wildcard" (or rather - regexp) fashion. This does not cause the module to create any chains (as the exact name to be created is not known), but any matching chain will be fully preserved, including all rules, counters etc, when ruleset is applied to kernel.

## Example usage

    # manage iptables
    include iptables

    # define structure of input rules
    iptables::chain::builtin { 'filter:INPUT':
      policy => 'DROP',
      jumps  => [
        'SERVICES',
      ],
    }

    # we are not router, drop forwarding
    iptables::chain::builtin { 'filter:FORWARD':
      policy => 'DROP',
    }

    # define structure of NAT rules
    iptables::chain::builtin { 'nat:PREROUTING':
      policy => 'ACCEPT',
      jumps  => [
        'LOAD_BALANCE',
      ],
    }

    # immutable chain, where the rule order matters
    iptables::chain::immutable { 'nat:LOAD_BALANCE':
      comment => 'balance web traffic to 2 workers',
      rules => [
        '-m tcp -p tcp --dport 80 -m statistic --mode nth --every 2 -j DNAT --to-destination 1.2.3.4:80',
        '-m tcp -p tcp --dport 80 -m statistic --mode nth --every 1 -j DNAT --to-destination 5.6.7.8:80',
      ],
    }

    # create chain for docker forwarding rules but do not manage the content
    iptables::chain::unmanaged { 'filter:DOCKER-USER' :
      comment => 'Used by Docker',
    }

    # preserve Calico chains when refreshing the ruleset
    iptables::chain::unmanaged { 'filter:/cali-(fw|tw)-cali[0-9a-f]{11}/' :
      comment => 'Calico forwarding chains',
    }

    # flexible chain for adding services (rule order does not matter)
    iptables::chain::open { 'filter:SERVICES':
      comment => 'put allowed services here',
    }

    # allow web server
    iptables::rule { 'ssh server':
      table   => 'filter',
      chain   => 'SERVICES',
      command => '-m tcp -p tcp --dport 22 -j ACCEPT',
    }

    # allow mail server
    iptables::rule { 'mail server':
      table   => 'filter',
      chain   => 'SERVICES',
      command => '-m tcp -p tcp --dport 25 -j ACCEPT',
    }

## Known problems
* does not sync definition file with runtime settings in the kernel, only on file refresh
* support for IPv4 only
