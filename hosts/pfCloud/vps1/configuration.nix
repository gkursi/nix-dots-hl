# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "wiregurarder"; # Define your hostname.

  networking.useDHCP = false;
  systemd.network.enable = true;

  systemd.network.networks."10-eth0" = {
    matchConfig.MACAddress = "00:16:3e:3b:33:c9";

    address = [
      "45.135.194.63/24"
      "2a14:7c2:1db9::1/48"
    ];

    networkConfig = {
      DHCP = "no";
      IPv6AcceptRA = false;
    };

    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = "45.135.194.1";
      }
      {
        Destination = "::/0";
        Gateway = "2a14:7c2::1";

        # Gateway is outside 2a14:7c2:1db9::/48
        GatewayOnLink = true;
      }
    ];

    linkConfig.RequiredForOnline = "routable";
  };

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
