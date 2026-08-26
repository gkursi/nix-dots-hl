nat: { ... }:
let

  srcInterface = nat.sourceInterface;
  sourcePort = nat.sourcePort;

  dstAddress = nat.destinationAddress;
  dstPort = nat.destinationPort;
  dstInterface = nat.destinationInterface;

  destination = "${dstAddress}:${toString dstPort}";
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

  networking.firewall.allowedTCPPorts = [ sourcePort dstPort ];
  networking.firewall.allowedUDPPorts = [ sourcePort dstPort ];
}
