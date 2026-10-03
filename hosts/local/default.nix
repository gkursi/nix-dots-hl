{ self, config }:
let
  peers = [
    # {
    #   address = "195.10.226.122";
    #   allowed = [ self.de24fire.vpsA.dns."vpsA.24fire.wg" ];
    #   key = self.de24fire.vpsA.modules.wireguard.publicKey;
    #   keepalive = true;
    # }

    {
      address = "45.135.194.63";
      allowed = [ self.pfCloud.mrrrrow.dns."mrrrow.pfcloud.wg" ];
      key = self.pfCloud.mrrrrow.modules.wireguard.publicKey;
      keepalive = true;
    }

    {
      address = "185.219.159.64";
      allowed = [ self.delska.mrrrrrow.dns."mrrrrrow.delska.wg" ];
      key = self.delska.mrrrrrow.modules.wireguard.publicKey;
      keepalive = true;
    }
  ];
in
{
  mrrow =
    let
      drive = self.local.mrrow.drives.primary;
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

        # redlib = { };

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

        bind = {
          inherit drive;
          listenAddress = "192.168.0.1";
          slaves = [
            "192.168.0.2"
            "192.168.0.5"
          ];
        };

        wireguard =
          let
            i2pPort = self.local.mrrow.modules.i2p.port;
          in
          {
            inherit peers;
            publicKey = "A4yN7pYdjBxtn6Es2CfinMCP3Ay8SiSzWANVlaMpXD4=";
            privateKey = "wg";

            address = [
              "${self.local.mrrow.dns."mrrow.local.wg"}/32"
            ];

            tcpPorts = config.servicePortsA ++ [
              i2pPort
            ];
            udpPorts = [ i2pPort ];
          };

        i2p = {
          interface = "wg0";
          # external = self.de24fire.vpsA.target;
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
          hosts = gen: gen.upstream "192.168.0.1" config.serviceConfigA;
          useTls = false;
        };
      };

      dns = {
        "mrrow.local.wg" = "192.168.0.1";
      };

      drives = {
        primary = "/mnt/container";
      };
    };

  mrrrow = {
    target = "192.168.8.40";

    modules = {
      wireguard =
        let
          i2pPort = self.local.mrrow.modules.i2p.port;
        in
        {
          publicKey = "aUa85pj9cUyt0HSsCfESkvMYxqzxGu2RYCr1OGVTeyI=";
          privateKey = "wg2";

          address = [
            "${self.local.mrrrow.dns."mrrrow.local.wg"}/32"
          ];

          peers = peers;

          tcpPorts = config.servicePortsB ++ [
            i2pPort
            25565
          ];
        };

      forgejo = {
        drive = self.local.mrrrow.drives.primary;
      };

      # mastodon = {
      #   drive = self.local.mrrrow.drives.primary;
      # };

      nginx = {
        hosts = gen: gen.upstream "192.168.0.4" config.serviceConfigB;
      };

      genericJava = {
        drive = "${self.local.mrrrow.drives.primary}/fabric";
        runCommand = [ "./run.sh" "-nogui" ];
        ports = [ "192.168.0.4:25565:25565" ];
      };
    };

    dns = {
      "mrrrow.local.wg" = "192.168.0.4";
    };

    drives = {
      primary = "/mnt/container";
    };
  };
}
