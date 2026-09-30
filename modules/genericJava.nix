java:
{ ... }:
let
  drive = java.drive;
  runCommand = java.runCommand or [ "java" "-jar" java.jar];
  ports = java.ports or [];
in
{
  virtualisation.arion.projects.java.settings = {
    services.server.service = {
      image = "eclipse-temurin:17";
      command = runCommand;
      working_dir = "/server";
      volumes = [ "${drive}:/server" ];
      ports = ports;
      restart = "unless-stopped";
      tty = true;
    };
  };
}
