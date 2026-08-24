machine:
{ ... }:
{
  virtualisation.arion.projects.www.settings = {
    services.www.service = {
      image = "ghcr.io/static-web-server/static-web-server:2";
      restart = "unless-stopped";

      ports = [
        "127.0.0.1:8084:8084"
      ];

      environment = {
        SERVER_PORT = "8084";
      };

      volumes = [
        "${../files/static-www}:/public:ro"
      ];

      capabilities = {
        ALL = false;
      };
    };
  };
}
