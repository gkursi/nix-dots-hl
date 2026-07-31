machine:
{ ... }:
let
  prefix = (import ../lib/volume.nix).getVolumePrefix machine "static-www";
in
{
  system.activationScripts.copyFiles = {
      text = ''
        mkdir -p ${prefix}/static-www/
        rm -rf ${prefix}/static-www/*
        cp -r ${../files/static-www}/* ${prefix}/static-www/
      '';
    };

  virtualisation.arion.projects.pihole.settings = {
    services.pihole.service = {
      image = "ghcr.io/static-web-server/static-web-server:2";
      restart = "unless-stopped";

      ports = [
        "127.0.0.1:8084:8084"
      ];

      environment = {
        SERVER_PORT = "8084";
      };

      volumes = [
        "${prefix}/static-www/:/public:ro"
      ];

      capabilities = {
        ALL = false;
      };
    };
  };
}
