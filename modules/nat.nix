{
  sourceInterface,
  sourcePort,
  destinationAddress,
  destinationPort,
  destinationInterface,
}:
{ ... }:
let
  destination = "${destinationAddress}:${toString destinationPort}";
in
{
  networking.nat = {
    enable = true;
    internalInterfaces = [ sourceInterface ];
    externalInterface = destinationInterface;

    forwardPorts = [
      { inherit sourcePort destination; proto = "tcp"; }
      { inherit sourcePort destination; proto = "udp"; }
    ];
  };

  networking.firewall.allowedTCPPorts = [ sourcePort destinationPort ];
  networking.firewall.allowedUDPPorts = [ sourcePort destinationPort ];
}
