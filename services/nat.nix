machine: { ... }:
let
  props = import ../lib/props.nix;

  srcInterface = props.getProperty machine "nat" "srcInterface";
  sourcePort = props.getProperty machine "nat" "srcPort"; # int

  dstAddress = props.getProperty machine "nat" "dstAddress";
  destPort = props.getProperty machine "nat" "dstPort"; # int
  dstInterface = props.getProperty machine "nat" "dstInterface";

  destination = "${dstAddress}:${toString destPort}";
in
{
  networking.nat = {
    enable = true;
    internalInterfaces = [ srcInterface ];
    externalInterface = dstInterface;

    forwardPorts = [
      { inherit sourcePort destination; proto = "tcp"; }
      { inherit sourcePort destination; proto = "udp"; }
    ];
  };

  networking.firewall.allowedTCPPorts = [ sourcePort destPort ];
  networking.firewall.allowedUDPPorts = [ sourcePort destPort ];
}
