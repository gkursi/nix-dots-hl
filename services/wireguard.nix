machine:
{ ... }:
let
  props = import ../lib/props.nix;
  secret_key = props.getProperty machine "wireguard" "private-key";
in
{
  sops.secrets.${secret_key} = {
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
      address = props.getProperty machine "wireguard" "address";
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

      wireguardPeers = props.getProperty machine "wireguard" "peers";
    };
  };
}
