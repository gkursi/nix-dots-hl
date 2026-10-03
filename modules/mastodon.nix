{ drive }:
{ config, ... }:
{
  sops.secrets.forgejo_base = {
    sopsFile = ../secrets/forgejo.yaml;
  };

  sops.secrets.forgejo_enc_deterministic = {
    sopsFile = ../secrets/forgejo.yaml;
  };

  sops.secrets.forgejo_enc_key_derive = {
    sopsFile = ../secrets/forgejo.yaml;
  };

  sops.secrets.forgejo_enc_primary_key = {
    sopsFile = ../secrets/forgejo.yaml;
  };

  sops.secrets.forgejo_vapid_private = {
    sopsFile = ../secrets/forgejo.yaml;
  };

  sops.templates."mastodon.env".content = ''
    # Federation
    # ----------
    # This identifies your server and cannot be changed safely later
    # ----------
    LOCAL_DOMAIN=gullible.fyi

    # Redis
    # -----
    REDIS_HOST=redis
    REDIS_PORT=6379

    # PostgreSQL
    # ----------
    DB_HOST=db
    DB_USER=postgres
    DB_NAME=postgres
    DB_PASS=
    DB_PORT=5432

    # # Elasticsearch (optional)
    # # ------------------------
    # ES_ENABLED=true
    # ES_HOST=localhost
    # ES_PORT=9200
    # # Authentication for ES (optional)
    # ES_USER=elastic
    # ES_PASS=password

    # Secrets
    # -------
    # Make sure to use `bundle exec rails secret` to generate secrets
    # -------
    SECRET_KEY_BASE=${config.sops.placeholder.forgejo_base}

    # Encryption secrets
    # ------------------
    ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=${config.sops.placeholder.forgejo_enc_deterministic}
    ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=${config.sops.placeholder.forgejo_enc_key_derive}
    ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=${config.sops.placeholder.forgejo_enc_primary_key}

    # Web Push
    # --------
    # Generate with `bundle exec rails mastodon:webpush:generate_vapid_key`
    # --------
    VAPID_PRIVATE_KEY=${config.sops.placeholder.forgejo_vapid_private}
    VAPID_PUBLIC_KEY=BNKZsU_5Qa5VngpyF3IAiTDxAqEwGzwABqDVeDwraxbLLWAkGSSsx3tuxEVUq5Y4Fob0JYfIeGPxd4V6WYqCP7s=

    # Sending mail
    # ------------
    SMTP_SERVER=exim
    SMTP_PORT=8025
    SMTP_LOGIN=
    SMTP_PASSWORD=
    SMTP_FROM_ADDRESS=no-reply@goobers.cloud

    # Optional list of hosts that are allowed to serve media for your instance
    # EXTRA_MEDIA_HOSTS=https://data.example1.com,https://data.example2.com

    # IP and session retention
    # -----------------------
    # Make sure to modify the scheduling of ip_cleanup_scheduler in config/sidekiq.yml
    # to be less than daily if you lower IP_RETENTION_PERIOD below two days (172800).
    # -----------------------
    IP_RETENTION_PERIOD=31556952
    SESSION_RETENTION_PERIOD=31556952

    RAILS_LOG_LEVEL=debug
  '';

  virtualisation.arion.projects.mastodon.settings = {
    services.db.service = {
      image = "postgres:14-alpine";
      networks = ["internal_network"];
      volumes = [ "${drive}/mastodon-postgres:/var/lib/postgresql/data" ];
      restart = "unless-stopped";

      healthcheck = {
        test = ["CMD" "pg_isready" "-U" "postgres"];
      };

      environment = {
        POSTGRES_HOST_AUTH_METHOD="trust";
      };
    };

    services.db.out.service = {
      shm_size = "256mb";
    };

    services.redis.service = {
      image = "redis:7-alpine";
      networks = ["internal_network"];
      volumes = [ "${drive}/mastodon-redis:/data" ];
      restart = "unless-stopped";

      healthcheck = {
        test = ["CMD" "redis-cli" "ping"];
      };
    };

    services.web.service = {
      image = "ghcr.io/mastodon/mastodon:v4.7.2";
      restart = "unless-stopped";
      env_file = [ config.sops.templates."mastodon.env".path ];
      command = "bundle exec puma -C config/puma.rb";
      networks = [ "internal_network" "external_network" ];
      volumes = [ "${drive}/mastodon-public:/mastodon/public/system" ];
      ports = [ "127.0.0.1:8088:3000" ];

      healthcheck = {
        test = ["CMD-SHELL" "curl -s --noproxy localhost localhost:3000/health | grep -q 'OK' || exit 1"];
      };

      depends_on = [
        "db"
        "redis"
      ];
    };

    services.streaming.service = {
      image = "ghcr.io/mastodon/mastodon-streaming:v4.7.2";
      restart = "unless-stopped";
      env_file = [ config.sops.templates."mastodon.env".path ];
      command = "node ./streaming/index.js";
      networks = ["internal_network" "external_network"];
      ports = [ "127.0.0.1:8089:4000" ];

      healthcheck = {
        test = ["CMD-SHELL" "curl -s --noproxy localhost localhost:4000/api/v1/streaming/health | grep -q 'OK' || exit 1"];
      };

      depends_on = [
        "db"
        "redis"
      ];
    };

    services.sidekiq.service = {
      image = "ghcr.io/mastodon/mastodon:v4.7.2";
      restart = "unless-stopped";
      env_file = [ config.sops.templates."mastodon.env".path ];
      command = "bundle exec sidekiq";
      depends_on = [
        "db"
        "redis"
      ];
      networks = ["internal_network" "external_network"];
      volumes = [ "${drive}/mastodon-public:/mastodon/public/system" ];

      healthcheck = {
        test = ["CMD-SHELL" "ps aux | grep '[s]idekiq\ 8' || false"];
      };
    };

    services.exim = {
      service = {
        image = "devture/exim-relay:4.98-r0-4";
        hostname = "goobers.cloud";

        networks = [
          "external_network"
        ];

        restart = "unless-stopped";

        environment = {
          RELAY_FROM_HOSTS = "172.30.0.0/24";
          RELAY_TO_DOMAINS = "*";
          LOCAL_DOMAINS = "";
          DISABLE_SENDER_VERIFICATION = "1";
        };

        expose = [
          "8025"
        ];
      };
    };

    networks.internal_network.internal = true;
    networks.external_network = {
      ipam = {
        config = [{ subnet = "172.30.0.0/24"; }];
      };
    };
  };
}
