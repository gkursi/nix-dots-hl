machine:
{ ... }:
{
  sops.secrets.wg = {
    sopsFile = ../secrets/wireguard.yaml;
    mode = "640";
    owner = "systemd-network";
    restartUnits = [ "systemd-networkd.service" ];
    path = "/etc/wireguard";
  };

  # sops.templates."wg".content = config.sops.placeholder.wg;

  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.useNetworkd = true;

  systemd.network = {
    enable = true;

    networks."50-wg0" = {
      matchConfig.Name = "wg0";

      address = [
        "fd31:bf08:57cb::7/128"
        "192.168.0.1/32"
      ];
    };

    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };

      wireguardConfig = {
        ListenPort = 51820;

        PrivateKeyFile = "/etc/wireguard";

        # To automatically create routes for everything in AllowedIPs
        RouteTable = "main";

        # FirewallMark marks all packets send and received by wg0
        # with the number 42, which can be used to define policy rules on these packets.
        FirewallMark = 42;
      };

      wireguardPeers = [
        {
          Endpoint = "45.135.194.63:51820";
          PublicKey = "J4qnoibtcjitzCHv7+2LH0M2rkg/CE7uDTxP/v+ykhU=";

          AllowedIPs = [
            "fd31:bf08:57cb::9/128"
            "192.168.0.2/32"
          ];

          # RouteTable can also be set in wireguardPeers
          # RouteTable in wireguardConfig will then be ignored.
          # RouteTable = 1000;

          PersistentKeepalive = 20;
        }
      ];
    };
  };
}
