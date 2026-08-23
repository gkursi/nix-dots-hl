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
      scopes = import ./hosts;

      mkHostModules =
        scope: hostname:
        [
          (import ./hosts/common.nix scopes.${scope}.${hostname})
          (import ./hosts/${scope}/common.nix scopes.${scope}.${hostname})
          ./hosts/${scope}/${hostname}/hardware-configuration.nix
          ./hosts/${scope}/${hostname}/configuration.nix

          arion.nixosModules.arion
          sops-nix.nixosModules.sops
        ]
        ++ (import ./services scopes.${scope}.${hostname})
        ++ (import ./network scopes.${scope}.${hostname});
    in
    {
      colmenaHive = colmena.lib.makeHive (
        {
          meta = {
            nixpkgs = import nixpkgs { system = system_architecture; };
          };
        }
        // builtins.foldl' (
          acc: scope:
          acc // nixpkgs.lib.genAttrs (builtins.attrNames scopes.${scope}) (hostname: {
            deployment.targetHost = scopes.${scope}.${hostname}.target;
            deployment.tags = scopes.${scope}.${hostname}.tags or [ ];
            imports = mkHostModules scope hostname;
          })
        ) {} (builtins.attrNames scopes)
      );
    };
}
