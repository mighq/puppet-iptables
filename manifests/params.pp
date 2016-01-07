class iptables::params() {
  $builtins = {
    raw    => ['PREROUTING', 'OUTPUT'],
    mangle => ['PREROUTING', 'INPUT', 'FORWARD', 'OUTPUT', 'POSTROUTING'],
    nat    => ['PREROUTING', 'OUTPUT'],
    filter => ['INPUT', 'FORWARD', 'OUTPUT'],
  }
  $targets = ['ACCEPT', 'DROP']
}