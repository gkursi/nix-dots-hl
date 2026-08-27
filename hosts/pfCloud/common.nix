host: { ... }: {
  networking.useDHCP = false;
  systemd.network.enable = true;

  systemd.network.networks."10-eth0" = {
    matchConfig.MACAddress = host.mac;

    address = [
      "${host.target}/24"
      "${host.target6}/48"
    ];

    networkConfig = {
      DHCP = "no";
      IPv6AcceptRA = false;
    };

    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = host.gateway;
      }
      {
        Destination = "::/0";
        Gateway = host.gateway6;
        GatewayOnLink = true;
      }
    ];

    linkConfig.RequiredForOnline = "routable";
  };

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];
}
