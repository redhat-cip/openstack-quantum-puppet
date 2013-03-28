class quantum::keystone::auth (
  $password,
  $auth_name          = 'quantum',
  $email              = 'quantum@localhost',
  $tenant             = 'services',
  $configure_endpoint = true,
  $service_type       = 'network',
  $public_address     = '127.0.0.1',
  $admin_address      = '127.0.0.1',
  $internal_address   = '127.0.0.1',
  $port               = '9696',
  $public_protocol    = 'http',
  $region             = 'RegionOne'
) {

  Keystone_user_role["${auth_name}@services"] ~> Service <| name == 'quantum-server' |>

  keystone_user { $auth_name:
    ensure   => present,
    password => $password,
    email    => $email,
    tenant   => $tenant,
  }
  keystone_user_role { "${auth_name}@services":
    ensure  => present,
    roles   => 'admin',
  }
  keystone_service { $auth_name:
    ensure      => present,
    type        => $service_type,
    description => "Quantum Networking Service",
  }

  if $configure_endpoint {
    keystone_endpoint { "$region/$auth_name":
      ensure       => present,
      region       => $region,
      public_url   => "${public_protocol}://${public_address}:${port}/",
      admin_url    => "http://${admin_address}:${port}/",
      internal_url => "http://${internal_address}:${port}/",
    }

  }
}
