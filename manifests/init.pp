class quantum (
  $rabbit_password,
  $enabled                = true,
  $package_ensure         = 'present',
  $verbose                = 'False',
  $debug                  = 'False',
  $bind_host              = '0.0.0.0',
  $bind_port              = '9696',
  $core_plugin            = 'quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2',
  $auth_strategy          = 'keystone',
  $base_mac               = 'fa:16:3e:00:00:00',
  $mac_generation_retries = 16,
  $dhcp_lease_duration    = 120,
  $allow_bulk             = 'True',
  $allow_overlapping_ips  = 'False',
  $control_exchange       = 'quantum',
  $rabbit_host            = 'localhost',
  $rabbit_port            = '5672',
  $rabbit_user            = 'guest',
  $rabbit_virtual_host    = '/'
) {
  include 'quantum::params'

  Package['quantum'] -> Quantum_config<||>

  file {'/etc/quantum':
    ensure  => directory,
    owner   => 'quantum',
    group   => 'root',
    mode    => 770,
    require => Package['quantum']
  }

  package {'quantum':
    name   => $::quantum::params::package_name,
    ensure => $package_ensure
  }

  quantum_config {
    'DEFAULT/verbose':                value => $verbose;
    'DEFAULT/debug':                  value => $debug;
    'DEFAULT/bind_host':              value => $bind_host;
    'DEFAULT/bind_port':              value => $bind_port;
    'DEFAULT/auth_strategy':          value => $auth_strategy;
    'DEFAULT/core_plugin':            value => $core_plugin;
    'DEFAULT/base_mac':               value => $base_mac;
    'DEFAULT/mac_generation_retries': value => $mac_generation_retries;
    'DEFAULT/dhcp_lease_duration':    value => $dhcp_lease_duration;
    'DEFAULT/allow_bulk':             value => $allow_bulk;
    'DEFAULT/allow_overlapping_ips':  value => $allow_overlapping_ips;
    'DEFAULT/control_exchange':       value => $control_exchange;
    'DEFAULT/rabbit_host':            value => $rabbit_host;
    'DEFAULT/rabbit_port':            value => $rabbit_port;
    'DEFAULT/rabbit_userid':          value => $rabbit_user;
    'DEFAULT/rabbit_password':        value => $rabbit_password;
    'DEFAULT/rabbit_virtual_host':    value => $rabbit_virtual_host;
  }
}
