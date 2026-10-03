{self, config}: {
  mrrrrow = {
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
          "${self.pfCloud.mrrrrow.dns."mrrrow.pfcloud.wg"}/32"
        ];

        peers = [
          {
            allowed = [ self.local.mrrow.dns."mrrow.local.wg" ];
            key = self.local.mrrow.modules.wireguard.publicKey;
          }
          {
            allowed = [ self.local.mrrrow.dns."mrrrow.local.wg" ];
            key = self.local.mrrrow.modules.wireguard.publicKey;
          }
        ];

        tcpPorts = config.servicePortsA ++ config.servicePortsB ++ [ 25565 ];
      };

      nginx = {
        hosts = gen:
          (gen.merge "0.0.0.0" "http://${self.local.mrrow.dns."mrrow.local.wg"}" config.serviceConfigA)
          // (gen.merge "0.0.0.0" "http://${self.local.mrrrow.dns."mrrrow.local.wg"}" config.serviceConfigB)
          // {
            "gullible.fyi" = {
              enableACME = true;
              forceSSL = true;

              locations."/" = {
                proxyPass = "http://192.168.0.4:8088";
                proxyWebsockets = true;
              };
            };
          };

        useTls = true; # this will force redirect any http connection to https
      };

      velocity = {};

      bind-slave = {
        bindAddrs = [ "192.168.0.2" "45.135.194.63" ];
        masters = [ "192.168.0.1" ];
      };
    };

    dns = {
      "mrrrow.pfcloud.wg" = "192.168.0.2";
    };
  };
}
