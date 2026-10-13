{ drive }:
{ ... }:
{
  virtualisation.arion.projects.api.settings = {
    services.api.service = {
      image = "debian:bookworm-slim";

      volumes = [
        "${drive}/api:/app"
      ];

      entrypoint = "/app/run";
      command = [ ];
      working_dir = "/app";

      ports = [
        "127.0.0.1:8090:8080"
        "192.168.8.40:3000:8081"
      ];

      restart = "unless-stopped";
    };
  };

  networking.firewall.allowedTCPPorts = [
    3000
  ];
}
