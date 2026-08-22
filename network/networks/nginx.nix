nginxAddress:
let
  nginx = import ../../lib/nginx.nix;
in
{
  setup = { ... }:
  {
    services.nginx = {
      enable = true;

      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
    };
  };

  moduleForHost = host: { ... }:
  let
    name = if host.name == "<root>" then "goobers.cloud" else "${host.name}.goobers.cloud";
  in
  {
    services.nginx.virtualHosts."${name}." = {
      listen = [
        {
          addr = nginxAddress;
          port = nginx.mapPort host.port;
          ssl = false;
        }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString host.port}";
      };
    };
  };
}
