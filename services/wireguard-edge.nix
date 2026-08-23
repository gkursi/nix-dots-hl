machine:
{ ... }:
let
  props = import ../lib/props.nix;
  secret_key = props.getProperty machine "wireguard-edge" "private-key";
  address = props.getProperty machine "wireguard-edge" "address";
in
{
  sops.secrets.${secret_key} = {
    sopsFile = ../secrets/wireguard-edge.yaml;
    mode = "640";
    owner = "systemd-network";
    restartUnits = [ "systemd-networkd.service" ];
    path = "/etc/wireguard";
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.useNetworkd = true;

  systemd.network = {
    enable = true;

    networks."50-wg0" = {
      matchConfig.Name = "wg0";
      address = address;
    };

    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
        MTUBytes = 1384;
      };

      wireguardConfig = {
        ListenPort = 51820;

        PrivateKeyFile = "/etc/wireguard";

        # To automatically create routes for everything in AllowedIPs
        RouteTable = "main";
      };

      wireguardPeers = [
        {
          PublicKey = "A4yN7pYdjBxtn6Es2CfinMCP3Ay8SiSzWANVlaMpXD4=";

          AllowedIPs = [
            "192.168.0.1/32"
          ];
        }
      ];
    };
  };
}
