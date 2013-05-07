# == Class: quantum::server
#
# Setup and configure the quantum API endpoint
#
# Parameters
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
# [*enabled*]
#   (optional) The state of the service
#   Defaults to true
#
# [*log_file*]
#   (optional) Where to log
#   Defaults to /var/log/quantum/server.log
#
# [*auth_password*]
#   (optional) The password to use for authentication (keystone)
#   Defaults to false. Set a value unless you are using noauth
#
# [*auth_type*]
#   (optional) What auth system to use
#   Defaults to 'keystone'. Can other be 'noauth'
#
# [*auth_host*]
#   (optional) The keystone host
#   Defaults to localhost
#
# [*auth_port*]
#   (optional) The keystone auth port
#   Defaults to 35357
#
# [*auth_tenant*]
#   (optional) The tenant of the auth user
#   Defaults to services
#
# [*auth_user*]
#   (optional) The name of the auth user
#   Defaults to quantum
#
# [*auth_protocol*]
#   (optional) The protocol to connect to keystone
#   Defaults to http
#
class quantum::server (
  $package_ensure = 'present',
  $enabled        = true,
  $auth_password  = false,
  $auth_type      = 'keystone',
  $auth_host      = 'localhost',
  $auth_port      = '35357',
  $auth_tenant    = 'services',
  $auth_user      = 'quantum',
  $auth_protocol  = 'http',
  $log_file       = '/var/log/quantum/server.log'
) {

  include quantum::params
  require keystone::python

  Quantum_config<||> ~> Service['quantum-server']
  Quantum_api_config<||> ~> Service['quantum-server']

  quantum_config {
    'DEFAULT/log_file':  value => $log_file
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  if ($::quantum::params::server_package) {
    Package['quantum-server'] -> Quantum_api_config<||>
    Package['quantum-server'] -> Quantum_config<||>
    package {'quantum-server':
      name   => $::quantum::params::server_package,
      ensure => $package_ensure
    }
  }

  if ($auth_type == 'keystone') {

    if ($auth_password == false) {
      fail('$auth_password must be set when using keystone authentication.')
    } else {
      quantum_config {
        'keystone_authtoken/auth_host':         value => $auth_host;
        'keystone_authtoken/auth_port':         value => $auth_port;
        'keystone_authtoken/auth_protocol':     value => $auth_protocol;
        'keystone_authtoken/admin_tenant_name': value => $auth_user;
        'keystone_authtoken/admin_user':        value => $auth_user;
        'keystone_authtoken/admin_password':    value => $keystone_password;
      }

      quantum_api_config {
        'filter:authtoken/auth_host':         value => $auth_host;
        'filter:authtoken/auth_port':         value => $auth_port;
        'filter:authtoken/admin_tenant_name': value => $auth_tenant;
        'filter:authtoken/admin_user':        value => $auth_user;
        'filter:authtoken/admin_password':    value => $keystone_password;
      }
    }
  }

  service {'quantum-server':
    name       => $::quantum::params::server_service,
    ensure     => $service_ensure,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true
  }
}
