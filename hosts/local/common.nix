machine:
{ ... }:
{
  # static ip
  networking.useDHCP = false;

  systemd.network.enable = true;
  systemd.network.networks."common-network" = {
    address = [
      "${machine.desiredIp or machine.target}/24"
    ];

    routes = [
      { Gateway = "fe80::1"; }
      { Gateway = "192.168.8.1"; }
    ];

    linkConfig = {
      RequiredForOnline = "routable";
      ActivationPolicy = "up";
    };
  };
}
