machine:
{ config, ... }:
let
  utils = import ../lib/volume.nix;
  prefix = utils.getVolumePrefix machine "invidious";

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
    # URL used for the internal communication between invidious and invidious companion
    # There is no need to change that except if Invidious companion does not run on the same docker compose file.
    - private_url: \"http://companion:8282/companion\"
    # IT is NOT recommended to use the same key as HMAC KEY. Generate a new key!
    # Use the key generated in the 2nd step
    invidious_companion_key: \"${config.sops.placeholder.companion}\"
    # external_port:
    # domain:
    # https_only: false
    # statistics_enabled: false
    # Use the key generated in the 1st step
    hmac_key: \"${config.sops.placeholder.invidious}\"
    "
  '';

  sops.templates."invidious-companion.env".content = ''
    SERVER_SECRET_KEY="${config.sops.placeholder.companion}"
  '';

  virtualisation.arion.projects.invidious.settings = {
    services.invidious.service = {
      image = "quay.io/invidious/invidious";
      restart = "unless-stopped";
      ports = [ "8083:3000" ];
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
        "${prefix}/cache:/var/tmp/youtubei.js:rw"
      ];
    };

    services.invidious-db.service = {
      image = "docker.io/library/postgres:14";
      restart = "unless-stopped";

      volumes = [
        "${prefix}/iv/postgres:/var/lib/postgresql/data"
        "${prefix}/iv/config/sql:/config/sql"
        "${prefix}/iv/docker/init-invidious-db.sh:/docker-entrypoint-initdb.d/init-invidious-db.sh"
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
