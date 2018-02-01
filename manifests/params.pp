class iptables::params() {
  $builtins = {
    raw    => ['PREROUTING', 'OUTPUT'],
    mangle => ['PREROUTING', 'INPUT', 'FORWARD', 'OUTPUT', 'POSTROUTING'],
    nat    => ['PREROUTING', 'POSTROUTING', 'OUTPUT'],
    filter => ['INPUT', 'FORWARD', 'OUTPUT'],
  }
  $policies = ['ACCEPT', 'DROP']

  $sync_script = 'iptables_sync'

  $definition_file = '/etc/sysconfig/iptables'

  $datacat_umc       = 'iptables/unmanaged_chains'
  $datacat_structure = 'iptables/structure'
}
