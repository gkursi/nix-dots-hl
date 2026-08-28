matrixConfig:
{ pkgs, ... }:
let
  drive = matrixConfig.drive;

  resolve = pkgs.writeText "resolv.conf" ''
    nameserver 1.0.0.1
    nameserver 1.1.1.1
  '';
in
{
  virtualisation.arion.projects.continuwuity.settings = {
    services.homeserver.service = {
      image = "forgejo.ellis.link/continuwuation/continuwuity:latest";
      command = "";
      restart = "unless-stopped";

      ports = [ "127.0.0.1:8008:8008" ];
      volumes = [
        "${resolve}:/etc/resolv.conf:ro"
        "${drive}/continuwuity/:/var/lib/continuwuity"
      ];

      environment = {
        CONTINUWUITY_SERVER_NAME = "meower.fyi";
        CONTINUWUITY_ADDRESS = "0.0.0.0";
        CONTINUWUITY_DATABASE_PATH = "/var/lib/continuwuity";
        CONTINUWUITY_PORT = 8008;
        CONTINUWUITY_WELL_KNOWN = ''
          {
            client=https://meower.fyi,
            server=meower.fyi:443
          }
        '';
        CONTINUWUITY_MATRIX_RTC__FOCI = ''[{ type = "livekit", livekit_service_url = "https://livekit.example.com" }]'';
      };
    };
  };
}
