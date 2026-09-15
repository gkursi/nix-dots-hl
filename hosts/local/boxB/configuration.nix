# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ ... }:
let
  common = {
    routes = [
      { Gateway = "fe80::1"; }
      { Gateway = "192.168.8.1"; }
    ];

    linkConfig = {
      RequiredForOnline = "routable";
      ActivationPolicy = "up";
    };
  };
in
{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/ata-SAMSUNG_SSD_PM871a_2.5_7mm_256GB_S2XNNX0J106257";
  networking.hostName = "kitty";
  system.stateVersion = "25.05";

  systemd.network.networks."10-common-network" = {
    matchConfig.Name = "enp0s31f6";
  };

  systemd.network.networks."50-fast-network-a" = common // {
    matchConfig.Name = "enp1s0f0";

    address = [
      "192.168.8.210/24"
    ];
  };

  systemd.network.networks."50-fast-network-b" = common // {
    matchConfig.Name = "enp1s0f1";

    address = [
      "192.168.8.220/24"
    ];
  };

  services.iperf3.bind = "192.168.8.210";

  boot.swraid.enable = true;
  boot.swraid.mdadmConf = "ARRAY /dev/md0 metadata=1.2 UUID=eda242e9:d46a85ec:ef2d6ce4:13b330d8";
}
