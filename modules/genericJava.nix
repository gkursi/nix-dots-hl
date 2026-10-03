{
  drive,
  jar,
  runCommand ? [ "java" "-jar" jar ],
  ports ? [],
}:
{ ... }:
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
