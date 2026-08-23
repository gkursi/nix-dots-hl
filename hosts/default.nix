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

        # depends on wireguard
        # nginx = {
        #   bind = "192.168.0.1";

        #   hosts = {
        #     "search.goobers.cloud" = 8080;
        #     "redlib.goobers.cloud" = 8082;
        #     "invidious.goobers.cloud" = 8083;
        #     "goobers.cloud" = 8084;
        #   };
        # };
      };

      network = {
        services = {
          "search" = 8080;
          "redlib" = 8082;
          "invidious" = 8083;
          "<root>" = 8084;
        };

        networks = [
          # wireguard and nginx depend on eachother
          # (nginx binds to the wireguard interface)
          (import ../network/networks/nginx.nix "192.168.0.1")
          ((import ../network/networks/wireguard.nix) {
            privateKeyId = "wg";
            address = [
              "fd31:bf08:57cb::7/128"
              "192.168.0.1/32"
            ];
          })

          (import ../network/networks/i2p.nix)
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
            "fd31:bf08:57cb::7/128"
            "192.168.0.3/32"
          ];
        };
      };

      network = {
        services = { };
        networks = [ ];
      };
    };
  };
}
