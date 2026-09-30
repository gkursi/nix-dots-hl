machine:
{...}:
{
  networking.useDHCP = false;
  networking.networkmanager.enable = false;
  systemd.network.enable = true;

  systemd.network.networks = {
    "10-internal" = {
      matchConfig.MACAddress = machine.internalMac;

      address = [
        "${machine.internalIp4}/24"
      ];

      networkConfig = {
        DHCP = "no";
        IPv6AcceptRA = false;
        LinkLocalAddressing = "ipv6";
      };

      linkConfig.RequiredForOnline = "no";
    };

    "20-external" = {
      matchConfig.MACAddress = machine.externalMac;

      address = [
        "${machine.externalIp4}/24"
      ];

      networkConfig = {
        DHCP = "no";
        IPv6AcceptRA = false;
        LinkLocalAddressing = "ipv6";
      };

      routes = [
        {
          Gateway = machine.gateway4;
          GatewayOnLink = true;
        }
      ];

      linkConfig.RequiredForOnline = "routable";
    };
  };
}
