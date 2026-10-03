{ self, ... }: {
  mrrrrrow = {
    internalMac = "02:00:0a:02:f3:01";
    internalIp4 = "10.2.243.1";
    externalMac = "02:00:b9:db:9f:40";
    externalIp4 = "185.219.159.64";
    gateway4 = "185.219.159.1";

    target = "185.219.159.64";

    modules = {
      wireguard = {
        publicKey = "pi181Cnf8U7bpeSOvWfuBS2AuUMYz9ergdcRfa4nZHA=";
        privateKey = "wireguard-edge-delska";

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

        address = [
          "${self.delska.mrrrrrow.dns."mrrrrrow.delska.wg"}/32"
        ];

        tcpPorts = [
          53
        ];
      };

      bind-slave = {
        bindAddrs = [ "192.168.0.5" "185.219.159.64" ];
        masters = [ "192.168.0.1" ];
      };
    };

    dns = {
      "mrrrrrow.delska.wg" = "192.168.0.5";
    };
  };
}
