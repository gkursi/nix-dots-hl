{ pkgs, ... }:

{
  boot.loader.grub = {
    enable = true;
    device = "/dev/disk/by-id/ata-M4-CT128M4SSD2_0000000012400917BCF8";
  };

  networking.hostName = "box-1";

  # static ip
  networking.useDHCP = false;

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "eno1";

    address = [
      "192.168.8.100/24"
    ];

    routes = [
      { Gateway = "fe80::1"; }
      { Gateway = "192.168.8.1"; }
    ];

    linkConfig = {
      RequiredForOnline = "routable";
      ActivationPolicy = "up";
    };
  };

  environment.systemPackages = [
    pkgs.vim
    pkgs.wget
  ];

  # ssh
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      MaxAuthTries = 1;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK3SZTiXahBcitMzd1gRo2B37B2zJs+YHiyW7OJxprxr qweru@archlinux"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEB8MtwQ8Zwf18sANLg2YuPQvILdtMvFR1oVEc233N9K"
  ];

  system.stateVersion = "25.11";
}
