wireguardConfig:
{ config, ... }:
{
  sops.secrets.${wireguardConfig.privateKey} = {
    sopsFile = ../secrets/wireguard.yaml;
    mode = "640";
    owner = "systemd-network";
    restartUnits = [ "systemd-networkd.service" ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.useNetworkd = true;

  networking.firewall.interfaces."wg0" = {
    allowedTCPPorts = wireguardConfig.tcpPorts or [ ];
    allowedUDPPorts = wireguardConfig.udpPorts or [ ];
  };

  systemd.network = {
    enable = true;

    networks."50-wg0" = {
      matchConfig.Name = "wg0";
      address = wireguardConfig.address;
    };

    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
        MTUBytes = 1384;
      };

      wireguardConfig = {
        ListenPort = 51820;

        PrivateKeyFile = config.sops.secrets.${wireguardConfig.privateKey}.path;

        # To automatically create routes for everything in AllowedIPs
        RouteTable = "main";
      };

      wireguardPeers = map (
        peer:
        {
          PublicKey = peer.key;
          AllowedIPs = peer.allowed;
        }
        // (if peer.keepalive or false then { PersistentKeepalive = 20; } else { })
        // (if peer.address or null != null then { Endpoint = "${peer.address}:51820"; } else { })
      ) wireguardConfig.peers;
    };
  };
}
