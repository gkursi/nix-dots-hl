let
  i2pPort = 11827;
in
{
  local = {
    boxA = {
      target = "192.168.8.100";

      services = {
        searxng = {
          drive = 0;
        };

        glance = {
          drive = 0;
        };

        redlib = { };

        invidious = {
          drive = 0;
        };

        static-www = {
          drive = 0;
        };

        upsmon-host = { };

        upsmon = {
          host = "localhost";
        };
      };

      network = {
        services = {
          "search" = 8080;
          "redlib" = 8082;
          "invidious" = 8083;
          "<root>" = 8084;
        };

        networks = [
          ((import ../network/networks/wireguard.nix) {
            privateKeyId = "wg";
            address = [
              "fd31:bf08:57cb::7/128"
              "192.168.0.1/32"
              "192.168.0.10/32"
            ];
          })

          (import ../network/networks/nginx.nix "192.168.0.1")
          (import ../network/networks/i2p.nix "195.10.226.122" "wg0" i2pPort)
        ];
      };

      drives = [ "/mnt/container" ];
      tags = [ "private" ];
    };
  };

  de24fire = {
    vpsA = {
      target = "195.10.226.122";
      target6 = "2a01:bc2:1:fda0::";
      gateway = "195.10.226.1";
      gateway6 = "2a01:bc2:1::1";

      services = {
        wireguard-edge = {
          # decrypted from secrets/wireguard-edge.yaml
          private-key = "wireguard-edge-24firede";

          address = [
            "192.168.0.3/32"
          ];

          allowedAddress = [
            "192.168.0.10/32"
          ];
        };

        nat = {
          srcInterface = "eth0";
          srcPort = i2pPort;

          dstInterface = "wg0";
          dstAddress = "192.168.0.10";
          dstPort = i2pPort;
        };
      };

      network = {
        services = { };
        networks = [ ];
      };
    };
  };
}
