class quantum::agents::ovs (
  $package_ensure       = 'present',
  $enabled              = true,
  $bridge_uplinks       = ['br-ex:eth1'],
  $use_bridge_uplink    = true,
  $bridge_mappings      = ['default:br-ex'],
  $integration_bridge   = 'br-int',
  $enable_tunneling     = false,
  $local_ip             = false,
  $tunnel_bridge        = 'br-tun'
) {

  include 'quantum::params'
  if $enable_tunneling and ! $local_ip {
    fail('Local ip for ovs agent must be set when tunneling is enabled')
  }

  include 'quantum::params'
  require 'vswitch::ovs'

  Package['quantum-plugin-ovs'] ->  Package['quantum-plugin-ovs-agent']
  Package['quantum-plugin-ovs-agent'] -> Quantum_plugin_ovs<||>
  Quantum_plugin_ovs<||> ~> Service["quantum-plugin-ovs-service"]
  Quantum_config<||> ~> Service['quantum-plugin-ovs-service']

  vs_bridge {$integration_bridge:
    ensure       => present,
    require      => Service['openvswitch-switch'],
    notify       => Service['quantum-plugin-ovs-service'],
  }

  if $enable_tunneling {
    vs_bridge {$tunnel_bridge:
      ensure       => present,
      require      => Service['openvswitch-switch'],
      notify       => Service['quantum-plugin-ovs-service'],
    }
  }

  if $use_bridge_uplink {
    quantum::plugins::ovs::bridge{$bridge_mappings:
      notify  => Service['quantum-plugin-ovs-service'],
    }
    quantum::plugins::ovs::port{$bridge_uplinks:
      notify  => Service['quantum-plugin-ovs-service'],
    }
  }

  package { 'quantum-plugin-ovs-agent':
    name    => $::quantum::params::ovs_agent_package,
    ensure  => $package_ensure,
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  quantum_plugin_ovs {
    'OVS/local_ip': value => $local_ip;
  }

  service { 'quantum-plugin-ovs-service':
    name       => $::quantum::params::ovs_agent_service,
    enable     => $enable,
    ensure     => $service_ensure,
    require    => [Package['quantum-plugin-ovs-agent']],
    hasstatus  => true,
    hasrestart => true,
  }
}
