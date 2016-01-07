# manage iptables
include iptables

# define structure of input rules
iptables::chain::builtin { 'filter:INPUT':
  policy => 'DROP',
  rules => [
    '-j SERVICES',
  ],
}

# we are not router, drop forwarding
iptables::chain::builtin { 'filter:FORWARD':
  policy => 'DROP',
}

# define structure of NAT rules
iptables::chain::builtin { 'nat:PREROUTING':
  policy => 'ACCEPT',
  rules => [
    '-j LOAD_BALANCE',
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

# TMP
iptables::rule { 'fallback allow':
  table   => 'filter',
  chain   => 'SERVICES',
  command => '-j ACCEPT',
}
