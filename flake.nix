{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    colmena = {
      url = "github:nix-community/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      colmena,
      arion,
      sops-nix,
      ...
    }:
    let
      system_architecture = "x86_64-linux";
      hosts = import ./hosts;

      mkHostModules =
        hostname:
        [
          ./hosts/common.nix
          ./hosts/${hostname}/hardware-configuration.nix
          ./hosts/${hostname}/configuration.nix

          arion.nixosModules.arion
          sops-nix.nixosModules.sops
        ]
        ++ map (service: ./services/${service}.nix) (hosts.${hostname}.services);
    in
    {
      colmenaHive = colmena.lib.makeHive (
        {
          meta = {
            nixpkgs = import nixpkgs { system = system_architecture; };
          };
        }
        // nixpkgs.lib.genAttrs (builtins.attrNames hosts) (hostname: {
          deployment.targetHost = hosts.${hostname}.target;
          deployment.tags = hosts.${hostname}.tags or [ ];
          imports = mkHostModules hostname;
        })
      );
    };
}
