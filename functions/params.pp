function g_server::params(
  Hash                  $options, # We ignore both of these arguments, but
  Puppet::LookupContext $context, # the function still needs to accept them.
) {
  $base_params = {
    'g_server::accounts::admin_groups' => ['wheel']
  }

  $os_params = case $facts['os']['family'] {
    'Debian': {
      {
        'g_server::accounts::admin_groups' => ['sudo']
      }
    }
    default: {
      {}
    }
  }

  $base_params + $os_params
}
