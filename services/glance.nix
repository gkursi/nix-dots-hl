{
  virtualisation.arion.projects.i2p.settings = {
    services.i2p.service = {
      image = "docker.io/glanceapp/glance";
      restart = "unless-stopped";
      ports = [ "8081:8080" ];
      volumes = [ "/etc/glance/config:/app/config" ];

      environment = {
          JVM_XMX = "512m";
          EXT_PORT = 45675;
      };
    };
  };
}
