class quantum::server (
  $auth_password,
  $package_ensure   = 'present',
  $enabled          = true,
  $log_file         = '/var/log/quantum/server.log',
  $auth_type        = 'keystone',
  $auth_host        = 'localhost',
  $auth_port        = '35357',
  $auth_tenant      = 'services',
  $auth_user        = 'quantum'
) {
  include 'quantum::params'

  require 'keystone::python'

  Package['quantum-server'] -> Quantum_api_config<||>
  Quantum_api_config<||> ~> Service['quantum-server']

  quantum_api_config {
    'filter:authtoken/auth_host':         value => $auth_host;
    'filter:authtoken/auth_port':         value => $auth_port;
    'filter:authtoken/admin_tenant_name': value => $auth_tenant;
    'filter:authtoken/admin_user':        value => $auth_user;
    'filter:authtoken/admin_password':    value => $auth_password;
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  package {'quantum-server':
    name   => $::quantum::params::server_package,
    ensure => $package_ensure
  }

  service {'quantum-server':
    name       => $::quantum::params::server_service,
    ensure     => $service_ensure,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => [Service['quantum-plugin-ovs-service']],
  }
}
