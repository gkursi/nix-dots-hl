machine:
{ ... }:
let
  ipv4 = machine.target;
  ipv6 = machine.target6;

  ipv4Gateway = machine.gateway;
  ipv6Gateway = machine.gateway6;
  mac = machine.mac;
in
{
  networking.useDHCP = false;
  systemd.network.enable = true;

  # equivalent of netplan's `match: macaddress` + `set-name: eth0`
  systemd.network.links."10-eth0" = {
    matchConfig.MACAddress = mac;
    linkConfig.Name = "eth0";
  };

  systemd.network.networks."10-eth0" = {
    matchConfig.MACAddress = mac;
    address = [
      "${ipv4}/24"
      "${ipv6}/64"
    ];
    dns = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    domains = [ "pve.org" ];
    routes = [
      { routeConfig.Gateway = ipv4Gateway; }
      {
        routeConfig = {
          Gateway = ipv6Gateway;
          GatewayOnLink = true;
        };
      }
    ];
    networkConfig.IPv6AcceptRA = false;
  };
}
