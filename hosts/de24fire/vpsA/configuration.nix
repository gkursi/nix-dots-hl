{ ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "wireguarderer2"; # Define your hostname.
  time.timeZone = "Europe/Amsterdam";

  system.activationScripts.a = {
    text = ''
      mkdir -p /mnt/container
    '';
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
