machine:

{ pkgs, ... }:
let
  utils = import ../lib/volume.nix;
  prefix = utils.getVolumePrefix machine "glance";

  config = pkgs.writeText "glance-config.yml" ''
    theme:
      background-color: 0 0 16
      primary-color: 43 59 81
      positive-color: 61 66 44
      negative-color: 6 96 59
    pages:
      - name: Home
        hide-desktop-navigation: true
        columns:
          - size: small
            widgets:
              - type: calendar
                first-day-of-week: monday

              - type: rss
                limit: 10
                collapse-after: 3
                cache: 6h
                feeds:
                  - url: https://selfh.st/rss/
                    title: selfh.st
                    limit: 4
          - size: full
            widgets:
              - type: group
                widgets:
                  - type: hacker-news
                  - type: lobsters

              # - type: videos
              #   channels:
              #     - UCXuqSBlHAE6Xw-yeJA0Tunw # Linus Tech Tips
              #     - UCR-DXc1voovS8nhAvccRZhg # Jeff Geerling
              #     - UCsBjURrPoezykLs9EqgamOA # Fireship
              #     - UCBJycsmduvYEL83R_U4JriQ # Marques Brownlee
              #     - UCHnyfMqiRRG1u-2MsSQLbXA # Veritasium

          - size: small
            widgets:
              - type: weather
                location: Riga, Latvia
                units: metric # alternatively "imperial"
                hour-format: 24h

              - type: markets
                markets:
                  - symbol: SPY
                    name: S&P 500
                  - symbol: BTC-USD
                    name: Bitcoin
                  - symbol: NVDA
                    name: NVIDIA
                  - symbol: AAPL
                    name: Apple
                  - symbol: MSFT
                    name: Microsoft

              - type: releases
                cache: 8h
                # Without authentication the Github API allows for up to 60 requests per hour. You can create a
                # read-only token from your Github account settings and use it here to increase the limit.
                # token: ...
                repositories:
                  - ccbluex/liquidbounce
                  - meteordevelopment/meteor-client
  '';
in
{
  virtualisation.arion.projects.glance.settings = {
    services.glance.service = {
      image = "docker.io/glanceapp/glance";
      restart = "unless-stopped";
      ports = [ "8081:8080" ];
      volumes = [
        "${prefix}/glance:/app/config"
        "${config}:/app/config/glance.yml:ro"
      ];

      environment = {
        JVM_XMX = "512m";
        EXT_PORT = 45675;
      };
    };
  };
}
