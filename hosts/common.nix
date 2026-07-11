server:
{
  pkgs,
  ...
}:
{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  virtualisation = {
    docker.enable = false;
    arion.backend = "podman-socket";

    podman = {
      enable = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  users.users.root.extraGroups = [ "podman" ];

  # static ip
  networking.useDHCP = false;

  systemd.network.enable = true;
  systemd.network.networks."common-network" = {
    address = [
      "${server.desiredIp or server.target}/24"
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
}
