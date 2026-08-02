machine:
{ ... }:
let
  mapLocalPort = port: port + 10000;
  mapLocalPorts = ports: map mapLocalPort ports;

  proxyLocalPort = port: {
    listen = [
      {
        addr = "192.168.0.1";
        port = mapLocalPort port;
        ssl = false;
      }
    ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
    };
  };
in
{
  services.nginx = {
    enable = true;

    virtualHosts."search.goobers.cloud" = proxyLocalPort 8080;
    virtualHosts."redlib.goobers.cloud" = proxyLocalPort 8082;
    virtualHosts."goobers.cloud" = proxyLocalPort 8084;
    virtualHosts."speedtest.goobers.cloud" = proxyLocalPort 5201;

    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
  };

  networking.firewall.interfaces."wg0".allowedTCPPorts = [ 80 443 ] ++ mapLocalPorts [ 8080 8082 8084 5201 ];
}
