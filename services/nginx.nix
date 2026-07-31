machine:
{ ... }:
{
  services.nginx = {
    enable = true;

    virtualHosts."search.goobers.cloud" = {
      listen = [
        {
          addr = "192.168.0.1";
          port = 18080;
          ssl = false;
        }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
      };
    };

    virtualHosts."goobers.cloud" = {
      listen = [
        {
          addr = "192.168.0.1";
          port = 18084;
          ssl = false;
        }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:8084";
      };
    };

    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
  };

  networking.firewall.interfaces."wg0".allowedTCPPorts = [ 80 443 18080 18084 ];
}
