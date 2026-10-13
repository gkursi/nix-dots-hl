{ drive }:
{ ... }:
{
  virtualisation.arion.projects.sharkey.settings = {
    services = {
      web.service = {
        image = "registry.activitypub.software/transfem-org/sharkey:latest";
        restart = "always";
        depends_on = {
          db.condition = "service_healthy";
          redis.condition = "service_healthy";
        };
        ports = [ "127.0.0.1:8089:3000" ];
        networks = [ "shonk" ];
        env_file = [ "${../files/Sharkey/docker.env}" ];
        environment = {
          NODE_OPTIONS = "--max-old-space-size=8192";
        };
        volumes = [
          "${drive}/sharkey/upload:/sharkey/files"
          "${../files/Sharkey}/:/sharkey/.config:ro"
        ];
      };

      redis.service = {
        image = "redis:7-alpine";
        restart = "always";
        networks = [ "shonk" ];
        volumes = [ "${drive}/sharkey/redis:/data" ];
        healthcheck = {
          test = [ "CMD" "redis-cli" "ping" ];
          interval = "5s";
          retries = 20;
        };
      };

      db.service = {
        image = "groonga/pgroonga:4.0.1-alpine-17";
        restart = "always";
        networks = [ "shonk" ];
        env_file = [ "${../files/Sharkey/docker.env}" ];
        volumes = [ "${drive}/sharkey/db:/var/lib/postgresql/data" ];
        healthcheck = {
          test = [ "CMD" "pg_isready" "-U" "example-misskey-user" "-d" "misskey" ];
          interval = "5s";
          retries = 20;
        };
      };
    };

    networks.shonk = { };
  };
}
