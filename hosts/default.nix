let
  serviceConfig = {
    "goobers.cloud" = 8084;
    "meower.fyi" = 8008;

    "search.goobers.cloud" = 8080;
    "redlib.goobers.cloud" = 8082;
    "invidious.goobers.cloud" = 8083;
    "sable.goobers.cloud" = 8085;
    "ntfy.goobers.cloud" = 8086;
  };

  servicePorts = builtins.attrValues serviceConfig;

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

            continuwuity = {
              inherit drive;
            };

            upsmon-host = { };

            upsmon = {
              host = "localhost";
            };

            sable = { };

            ntfy = {
              inherit drive;
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
                    allowed = [ self.pfCloud.vps1.dns."vps1.pfcloud.wg" ];
                    key = self.pfCloud.vps1.modules.wireguard.publicKey;
                    keepalive = true;
                  }
                ];

                tcpPorts = [
                  i2pPort
                ]
                ++ servicePorts;
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
              hosts = gen: gen.upstream "192.168.0.1" serviceConfig;
              useTls = false;
            };
          };

          dns = {
            "boxA.local.wg" = "192.168.0.1";
          };

          drives = {
            primary = "/mnt/container";
          };
        };

      boxB = {
        target = "192.168.8.55";
        desiredIp = "192.168.8.200";
      };
    };

    de24fire = {
      vpsA = {
        mac = "bc:24:11:b5:2e:94";
        target = "195.10.226.122";
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
                  allowed = [ self.local.boxA.dns."boxA.local.wg" ];
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
              destinationAddress = self.local.boxA.dns."boxA.local.wg";
              destinationPort = i2pPort;
            };

          livekit = { };

          nginx = {
            hosts = gen: {
              "livekit.meower.fyi" = {
                forceSSL = true;
                enableACME = true;

                locations."~ ^/(sfu/get|healthz|get_token)" = {
                  proxyPass = "http://127.0.0.1:8081";
                  extraConfig = ''
                    proxy_buffering off;
                  '';
                };

                locations."/" = {
                  proxyPass = "http://127.0.0.1:7880";
                  extraConfig = ''
                    proxy_buffering off;
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection $connection_upgrade;
                  '';
                };
              };
            };

            useTls = true;
          };
        };
      };
    };

    pfCloud = {
      vps1 = {
        mac = "00:16:3e:3b:33:c9";
        target = "45.135.194.63";
        target6 = "2a14:7c2:1db9::1";
        gateway = "45.135.194.1";
        gateway6 = "2a14:7c2::1";

        modules = {
          wireguard = {
            privateKey = "wireguard-edge-pfcloud";
            publicKey = "I90CllIbEBKcg+wb02GDcvZEy+1x4xIsDNBXCTq/Vms=";

            address = [
              "${self.pfCloud.vps1.dns."vps1.pfcloud.wg"}/32"
            ];

            peers = [
              {
                allowed = [ self.local.boxA.dns."boxA.local.wg" ];
                key = self.local.boxA.modules.wireguard.publicKey;
              }
            ];

            tcpPorts = servicePorts;
          };

          nginx = {
            # all hosts are merged into a single port
            hosts = gen: gen.merge "0.0.0.0" "http://${self.local.boxA.dns."boxA.local.wg"}" serviceConfig;

            useTls = true; # this will force redirect any http connection to https
          };
        };

        dns = {
          "vps1.pfcloud.wg" = "192.168.0.2";
        };
      };
    };
  };
in
self
