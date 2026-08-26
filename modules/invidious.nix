inv:
{ config, ... }:
let
  secret_file = ../secrets/invidious.yaml;
in
{
  sops.secrets = {
    invidious.sopsFile = secret_file;
    companion.sopsFile = secret_file;
  };

  sops.templates."invidious.env".content = ''
    INVIDIOUS_CONFIG="
      db:
        dbname: invidious
        user: kemal
        password: kemal
        host: invidious-db
        port: 5432
      check_tables: true
      invidious_companion:
      - private_url: \"http://companion:8282/companion\"
      invidious_companion_key: \"${config.sops.placeholder.companion}\"
      external_port: 443
      domain: invidious.goobers.cloud
      registration_enabled: false
      disable_abusable_api: true
      hmac_key: \"${config.sops.placeholder.invidious}\"

      default_user_preferences:
        quality: medium
    "
  '';

  sops.templates."invidious-companion.env".content = ''
    SERVER_SECRET_KEY="${config.sops.placeholder.companion}"
  '';

  virtualisation.arion.projects.invidious.settings = {
    services.invidious.service = {
      image = "quay.io/invidious/invidious";
      restart = "unless-stopped";
      ports = [ "127.0.0.1:8083:3000" ];
      env_file = [ config.sops.templates."invidious.env".path ];
      depends_on = [ "invidious-db" ];

      healthcheck = {
        interval = "30s";
        timeout = "5s";
        retries = 2;
        test = [ "CMD-SHELL" "wget -nv --tries=1 --spider http://127.0.0.1:3000/api/v1/stats || exit 1" ];
      };
    };

    services.companion.service = {
      image = "quay.io/invidious/invidious-companion:latest";
      env_file = [ config.sops.templates."invidious-companion.env".path ];
      restart = "unless-stopped";
      capabilities.ALL = false;
      hostStoreAsReadOnly = true;

      volumes = [
        "${inv.drive}/cache:/var/tmp/youtubei.js:rw"
      ];
    };

    services.invidious-db.service = {
      image = "docker.io/library/postgres:14";
      restart = "unless-stopped";

      volumes = [
        "${inv.drive}/iv/postgres:/var/lib/postgresql/data"
        "${inv.drive}/iv/config/sql:/config/sql"
        "${inv.drive}/iv/docker/init-invidious-db.sh:/docker-entrypoint-initdb.d/init-invidious-db.sh"
      ];

      environment = {
        POSTGRES_DB = "invidious";
        POSTGRES_USER = "kemal";
        POSTGRES_PASSWORD = "kemal";
      };

      healthcheck.test = [ "CMD-SHELL" "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB" ];
    };
  };
}
