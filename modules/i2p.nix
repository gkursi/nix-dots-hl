{
  port,
  interface,
  tunnels,
}:
{ config, pkgs, ... }: {
  services.i2pd = {
    inherit port;
    enable = true;
    bandwidth = 16;
    enableIPv6 = true;
    family = "goobers-cloud";

    proto.http = {
      enable = true;
      address = "0.0.0.0";
      strictHeaders = false;
    };

    proto.httpProxy = {
      enable = true;
      address = "0.0.0.0";
    };

    # address = i2pConfig.external;
    ifname4 = interface;

    inTunnels = builtins.mapAttrs (host: cfg: {
      keys = "${host}-keys.dat";
      name = host;
      port = cfg.port;
      # nginx by default only proxies http, so other service types would break anyways
      type = cfg.type;
      address = cfg.address;
    }) tunnels;
  };

  networking.firewall.allowedTCPPorts = [
    7070
    4444
    port
  ];

  networking.firewall.allowedUDPPorts = [
    port
  ];

  # we love the nixpkgs maintainers
  fileSystems."/var/lib/i2pd" = {
    device = "/mnt/container/i2pd";
    options = [ "bind" ];
    fsType = "none";
  };

  system.activationScripts.copyFiles = {
    text = ''
      mkdir -p /var/lib/i2pd/family/
      rm -rf /mnt/container/i2pd/family/*
      cp -r ${../files/i2pd}/* /mnt/container/i2pd/family/.
    '';
  };

  systemd.services.i2pd.serviceConfig.ExecStartPre = [
    "+${pkgs.coreutils}/bin/install -m 0400 -o i2pd -g i2pd ${
      config.sops.secrets."i2p-family-key".path
    } /var/lib/i2pd/family/goobers-cloud.key"
  ];

  systemd.tmpfiles.rules = [
    "Z /mnt/container/i2pd 0700 i2pd i2pd - -"
  ];

  sops.secrets."i2p-family-key" = {
    sopsFile = ../secrets/goobers-cloud.key.json;
    format = "binary";
    owner = "root";
  };
}
