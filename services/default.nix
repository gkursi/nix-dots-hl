host:
  map
    (service: import ./${service}.nix host)
    (builtins.attrNames host.services)
