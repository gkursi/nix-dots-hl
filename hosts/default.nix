{
  boxA = {
    target = "192.168.8.100";

    services = {
      searxng = {
        drive = 0;
      };

      i2p = {
        drive = 0;
      };

      glance = {
        drive = 0;
      };

      redlib = { };

      invidious = {
        drive = 0;
      };

      upsmon-host = { };

      upsmon = {
        host = "localhost";
      };

      wireguard = {
        # decrypted from secrets/wireguard.yaml
        private-key = "wg";

        address = [
          "fd31:bf08:57cb::7/128"
          "192.168.0.1/32"
        ];

        peers = [
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

    drives = [ "/mnt/container" ];
    tags = [ "private" ];
  };
}
