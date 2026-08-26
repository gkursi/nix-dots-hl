let
  self = {
    local = {
      boxA =
        let
          drive = self.local.boxA.drives.primary;
        in
        {
          target = "192.168.8.100";

          modules = {
            searxng = {
              inherit drive;
            };

            glance = {
              inherit drive;
            };

            redlib = { };

            invidious = {
              inherit drive;
            };

            static-www = {
              inherit drive;
            };

            upsmon-host = { };

            upsmon = {
              host = "localhost";
            };

            wireguard =
              let
                i2pPort = self.local.boxA.modules.i2p.port;
              in
              {
                publicKey = "A4yN7pYdjBxtn6Es2CfinMCP3Ay8SiSzWANVlaMpXD4=";
                privateKey = "wg";

                address = [
                  "${self.local.boxA.dns."boxA.local.wg"}/32"
                  "${self.local.boxA.dns."boxA-pub.local.wg"}/32"
                ];

                peers = [
                  {
                    address = "195.10.226.122";
                    allowed = [ self.de24fire.vpsA.dns."vpsA.24fire.wg" ];
                    key = self.de24fire.vpsA.modules.wireguard.publicKey;
                    keepalive = true;
                  }

                  {
                    address = "45.135.194.63";
                    #allowed = [ self.pfCloud.vps1.dns."vps1.pfcloud.wg" ];
                    #key = self.pfCloud.vps1.modules.wireguard.publicKey;
                    allowed = [ "192.168.0.2" ];
                    key = "J4qnoibtcjitzCHv7+2LH0M2rkg/CE7uDTxP/v+ykhU=";
                    keepalive = true;
                  }
                ];

                tcpPorts = [
                  8080
                  8082
                  8083
                  8084
                  i2pPort
                ];
                udpPorts = [ i2pPort ];
              };

            i2p = {
              interface = "wg0";
              external = self.de24fire.vpsA.target;
              port = 11827;

              tunnels = {
                "search" = {
                  type = "http";
                  address = "127.0.0.1";
                  port = 8080;
                };
              };
            };

            nginx = {
              # each host has its own port
              hosts =
                gen:
                gen.upstream self.local.boxA.dns."boxA.local.wg" {
                  "search.goobers.cloud" = 8080;
                  "redlib.goobers.cloud" = 8082;
                  "invidious.goobers.cloud" = 8083;
                  "goobers.cloud" = 8084;
                };

              useTls = false;
            };
          };

          dns = {
            "boxA.local.wg" = "192.168.0.1";
            "boxA-pub.local.wg" = "192.168.0.10";
          };

          drives = {
            primary = "/mnt/container";
          };
          tags = [ "private" ];
        };
    };

    de24fire = {
      vpsA = {
        target = "195.10.226.122";
        # 24fire specific
        target6 = "2a01:bc2:1:fda0::";
        gateway = "195.10.226.1";
        gateway6 = "2a01:bc2:1::1";

        dns = {
          "vpsA.24fire.wg" = "192.168.0.3";
        };

        modules = {
          wireguard =
            let
              i2pPort = self.local.boxA.modules.i2p.port;
            in
            {
              # decrypted from secrets/wireguard-edge.yaml
              privateKey = "wireguard-edge-24firede";
              publicKey = "oBpW9PlQX4HWzsMq2OroFJMhVEEA/jKpqfeMEOG6Vxw=";

              address = [
                "${self.de24fire.vpsA.dns."vpsA.24fire.wg"}/32"
              ];

              peers = [
                {
                  allowed = [ self.local.boxA.dns."boxA-pub.local.wg" ];
                  key = self.local.boxA.modules.wireguard.publicKey;
                }
              ];

              tcpPorts = [ i2pPort ];
              udpPorts = [ i2pPort ];
            };

          nat =
            let
              i2pPort = self.local.boxA.modules.i2p.port;
            in
            {
              sourceInterface = "eth0";
              sourcePort = i2pPort;

              destinationInterface = "wg0";
              destinationAddress = self.local.boxA.dns."boxA-pub.local.wg";
              destinationPort = i2pPort;
            };
        };
      };
    };

    # pfCloud = {
    #   vps1 = {
    #     modules = {
    #       wireguard = {
    #         privateKey = "wireguard-edge-pfcloud";
    #         publicKey = "J4qnoibtcjitzCHv7+2LH0M2rkg/CE7uDTxP/v+ykhU=";

    #         address = [
    #           "${self.pfCloud.vps1.dns."vps1.pfcloud.wg"}/32"
    #         ];

    #         peers = [
    #           {
    #             allowed = [ self.local.boxA.dns."boxA.local.wg" ];
    #             key = self.local.boxA.modules.wireguard.publicKey;
    #           }
    #         ];

    #         tcpPorts = [ 8080 8082 8083 8084 ];
    #       };

    #       nginx = {
    #         # all hosts are merged into a single port
    #         hosts = gen: gen.merge {
    #           "search.goobers.cloud" = 8080;
    #           "redlib.goobers.cloud" = 8082;
    #           "invidious.goobers.cloud" = 8083;
    #           "goobers.cloud" = 8084;
    #         };

    #         useTls = true; # this will force redirect any http connection to https
    #       };
    #     };

    #     dns = {
    #       "vps1.pfcloud.wg" = "192.168.0.2";
    #     };
    #   };
    # };
  };
in
self
