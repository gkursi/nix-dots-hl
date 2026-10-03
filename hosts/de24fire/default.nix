{ self, ... }: {
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
          i2pPort = self.local.mrrow.modules.i2p.port;
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
              allowed = [ self.local.mrrow.dns."mrrow.local.wg" ];
              key = self.local.mrrow.modules.wireguard.publicKey;
            }
            {
              allowed = [ self.local.mrrrow.dns."mrrrow.local.wg" ];
              key = self.local.mrrrow.modules.wireguard.publicKey;
            }
          ];

          tcpPorts = [ i2pPort ];
          udpPorts = [ i2pPort ];
        };

      nat =
        let
          i2pPort = self.local.mrrow.modules.i2p.port;
        in
        {
          sourceInterface = "eth0";
          sourcePort = i2pPort;

          destinationInterface = "wg0";
          destinationAddress = self.local.mrrow.dns."mrrow.local.wg";
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
}
