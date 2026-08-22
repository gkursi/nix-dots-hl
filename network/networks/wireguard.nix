# depends on nginx
wireguardConfig:
let
  nginx = import ../../lib/nginx.nix;
in
{
  setup =
    { ... }:
      let
        privateKey = wireguardConfig.privateKeyId;
      in
      {
        sops.secrets.${privateKey} = {
          sopsFile = ../../secrets/wireguard.yaml;
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

              PrivateKeyFile = "/etc/wireguard";

              # To automatically create routes for everything in AllowedIPs
              RouteTable = "main";
            };

            wireguardPeers = [
              {
                Endpoint = "45.135.194.63:51820";
                PublicKey = "J4qnoibtcjitzCHv7+2LH0M2rkg/CE7uDTxP/v+ykhU=";

                AllowedIPs = [
                  "fd31:bf08:57cb::9/128"
                  "192.168.0.2/32"
                ];

                PersistentKeepalive = 20;
              }
            ];
          };
        };
      };

  moduleForHost = host: { ... }: {
    networking.firewall.interfaces."wg0".allowedTCPPorts = [ (nginx.mapPort host.port) ];
  };
}
