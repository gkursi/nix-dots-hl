forgejoConfig:
{ ... }:
let
  drive = forgejoConfig.drive;

in
{
  virtualisation.arion.projects.forgejo.settings = {
    services.forgejo.service = {
      image = "codeberg.org/forgejo/forgejo:16";
      restart = "unless-stopped";
      ports = [
        "127.0.0.1:8087:3000"
        "192.168.0.4:222:22"
      ];
      environment = {
        USER_UID=1000;
        USER_GID=1000;
      };
      networks = [ "forgejo" ];
      depends_on = [ "db" ];
      volumes = [
        # todo
        # "${config}:/data/gitea/conf/app.ini:ro"
        "${drive}/forgejo:/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };

    services.db.service = {
      image = "postgres:14";
      restart = "unless-stopped";
      environment = {
        POSTGRES_USER="forgejo";
        POSTGRES_PASSWORD="forgejo";
        POSTGRES_DB="forgejo";
      };
      networks = [ "forgejo" ];
      volumes = [
        "${drive}/forgejo-postgres:/var/lib/postgresql/data"
      ];
    };

    networks.forgejo = {};
  };
}
