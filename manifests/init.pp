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
  $rabbit_hosts           = ['localhost'],
  $rabbit_user            = 'guest',
  $rabbit_virtual_host    = '/'
) {
  include 'quantum::params'

  Package['quantum'] -> Quantum_config<||>

  File {
    require => Package['quantum-common'],
    owner   => 'root',
    group   => 'quantum',
    mode    => '750',
  }

  file {'/etc/quantum':
    ensure  => directory,
    owner   => 'root',
    group   => 'quantum',
    mode    => 750,
    require => Package['quantum']
  }

  file { '/etc/quantum/quantum.conf':
    owner => 'root',
    mode  => '0640',
  }

  file {'/etc/quantum/rootwrap.conf':
    ensure => present,
    source => 'puppet:///modules/quantum/rootwrap.conf',
    require => File['/etc/quantum'],
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
    'DEFAULT/rabbit_hosts':           value => join($rabbit_hosts, ',');
    'DEFAULT/rabbit_userid':          value => $rabbit_user;
    'DEFAULT/rabbit_password':        value => $rabbit_password;
    'DEFAULT/rabbit_virtual_host':    value => $rabbit_virtual_host;
    'DEFAULT/rootwrap_conf':	      value => '/etc/quantum/rootwrap.conf';
  }

  # Any machine using Quantum / OVS endpoints with certain nova networking configs will
  # have protetion issues writing unexpected files unless qemu is changed appropriately.
  @file { "/etc/libvirt/qemu.conf":
    ensure => present,
    notify => Exec[ '/etc/init.d/libvirt-bin restart'],
    source => 'puppet:///modules/quantum/qemu.conf',
  }
  exec { '/etc/init.d/libvirt-bin restart':
 	  refreshonly => true,
 	}
}
