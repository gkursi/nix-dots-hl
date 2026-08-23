machine:

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

  # iperf3
  services.iperf3 = {
    enable = true;
    openFirewall = true;
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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEB8MtwQ8Zwf18sANLg2YuPQvILdtMvFR1oVEc233N9K"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBoBdFBX4Vlh7D9g13MiNLmHsK/fPKAmIP69kaWL7I8l"
  ];

  # fail2ban
  services.fail2ban = {
    enable = true;
    bantime = "24h";
    maxretry = 2;

    ignoreIP = [
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];

    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h"; # 1 week
      overalljails = true;
    };
  };
}
