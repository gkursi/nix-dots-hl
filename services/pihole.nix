machine:

{ config, ... }: let
  utils = import ../lib/volume.nix;
  prefix = utils.getVolumePrefix machine "pihole";
  password = config.sops.secrets.pihole_admin_password.path;
in
{
  sops.secrets.pihole_admin_password = {
    sopsFile = ../secrets/pihole.yaml;
    mode = "0400";
    owner = "root";
    restartUnits = [ "arion-pihole.service" ];
  };

  virtualisation.arion.projects.pihole.settings = {
    services.pihole.service = {
      image = "docker.io/pihole/pihole:latest";
      restart = "unless-stopped";

      ports = [
        # http(s)
        "80:80/tcp"
        "443:443/tcp"

        # dns
        "53:53/tcp"
        "53:53/udp"
      ];

      volumes = [
        "${prefix}/pihole:/etc/pihole"
        "${password}:/run/pihole/secret"
      ];

      environment = {
        TZ = "Europe/Riga";
        FTLCONF_dns_listeningMode = "ALL";
        WEBPASSWORD_FILE = "/run/pihole/secret";
      };

      capabilities = {
        # NET_ADMIN = true; # required for DHCP
        # SYS_TIME = true; # required for NTP
        SYS_NICE = true; # extra processing time
      };
    };
  };
}
