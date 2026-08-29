# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  networking.hostName = "kitty";
  system.stateVersion = "25.05";
  systemd.network.networks."common-network" = {
    matchConfig.Name = "enp0s31f6";
  };
}
