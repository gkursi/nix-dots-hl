machine:
{ config, ... }:
{
  sops.secrets.livekit-key = {
    sopsFile = ../secrets/livekit.yaml;
  };

  sops.secrets.livekit-secret = {
    sopsFile = ../secrets/livekit.yaml;
  };

  sops.templates."livekit.env".content = ''
    LIVEKIT_JWT_BIND=:8081
    LIVEKIT_URL=wss://livekit.example.com
    LIVEKIT_FULL_ACCESS_HOMESERVERS=meower.fyi
    LIVEKIT_KEY=${config.sops.placeholder.livekit-key}
    LIVEKIT_SECRET=${config.sops.placeholder.livekit-secret}
  '';

  sops.templates."livekit.yaml".content = ''
    port: 7880
    bind_addresses:
      - ""
    rtc:
      tcp_port: 7881
      port_range_start: 50100
      port_range_end: 50200
      use_external_ip: true
      enable_loopback_candidate: false
    keys:
      ${config.sops.placeholder.livekit-key}: ${config.sops.placeholder.livekit-secret}

    # do not create rooms by default
    room:
      auto_create: false
  '';

  networking.firewall.allowedTCPPorts = [ 7881 ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 50100;
      to = 50200;
    }
  ];

  virtualisation.arion.projects.livekit.settings = {
    services.lk-jwt-service.service = {
      image = "ghcr.io/element-hq/lk-jwt-service:latest";
      restart = "unless-stopped";
      env_file = [ config.sops.templates."livekit.env".path ];
      ports = [ "8081:8081" ];
    };

    services.livekit.service = {
      image = "livekit/livekit-server:latest";
      restart = "unless-stopped";
      ports = [
        "127.0.0.1:7880:7880/tcp"
        "7881:7881/tcp"
        "50100-50200:50100-50200/udp"
      ];
      volumes = [ "${config.sops.templates."livekit.yaml".path}:/etc/livekit.yaml:ro" ];
    };
  };
}
