java:
{ ... }:
{
  virtualisation.arion.projects.velocity.settings = {
    services.server-fwd.service = {
      image = "alpine/socat"; # budget velocity
      command = "TCP-LISTEN:25565,fork,reuseaddr TCP:192.168.0.4:25565";
      ports = [ "25565:25565" ];
      restart = "unless-stopped";
      tty = true;
    };

    services.ssh-fwd.service = {
      image = "alpine/socat"; # budget velocity
      command = "TCP-LISTEN:222,fork,reuseaddr TCP:192.168.0.4:222";
      ports = [ "222:222" ];
      restart = "unless-stopped";
      tty = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    25565
    222
  ];
}
