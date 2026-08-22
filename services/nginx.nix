machine:
{ ... }:
let
  props = import ../lib/props.nix;
  hosts = props.getProperty machine "nginx" "hosts";
  extraPorts = props.getPropertyOrDefault machine "nginx" "ports" [];
  address = props.getProperty machine "nginx" "bind";

  mapLocalPort = port: port + 10000;
  mapLocalPorts = ports: map mapLocalPort ports;

  proxyLocalPort = port: {
    listen = [
      {
        addr = address;
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

    virtualHosts = builtins.mapAttrs (name: value: proxyLocalPort value) hosts;

    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
  };

  networking.firewall.interfaces."wg0".allowedTCPPorts = [ 80 443 ] ++ mapLocalPorts ([ 5201 ] ++ extraPorts ++ builtins.attrValues hosts);
}
