{
  virtualisation.arion.projects.i2p.settings = {
    services.i2p.service = {
      image = "docker.io/geti2p/i2p:latest";
      restart = "unless-stopped";

      ports = [
        "4444:4444" # http proxy
        "7657:7657" # router console
        # "6668:6668" # irc proxy
        "45675:45675" # i2np tcp
        "45675:45675/udp" # i2np udp
      ];

      volumes = [
        "/etc/i2p/config:/i2p/.i2p"
        "/etc/i2p/torrents:/i2psnark"
      ];

      environment = {
          JVM_XMX = "512m";
          EXT_PORT = 45675;
      };
    };
  };
}
