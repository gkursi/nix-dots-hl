# processor for a hosts network config
machine:
  builtins.concatMap
    (network: [ network.setup ] ++ builtins.attrValues (builtins.mapAttrs (name: value: network.moduleForHost { name = name; port = value; }) machine.network.services))
    machine.network.networks
