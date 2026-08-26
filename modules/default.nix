host:
  map
    (module: import ./${module}.nix host.modules.${module})
    (builtins.attrNames host.modules)
