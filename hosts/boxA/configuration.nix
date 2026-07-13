{ ... }:

{
  boot.loader.grub = {
    enable = true;
    device = "/dev/disk/by-id/ata-M4-CT128M4SSD2_0000000012400917BCF8";
  };

  fileSystems."/mnt/container" = {
    device = "/dev/disk/by-label/DOCKER";
    fsType = "ext4";
  };

  networking.hostName = "box-A";

  systemd.network.networks."common-network" = {
    matchConfig.Name = "eno1";
  };

  system.stateVersion = "25.11";
}
