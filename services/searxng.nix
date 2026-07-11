{ config, pkgs, ... }:
let
  settingsTemplate = pkgs.writeText "searxng-settings.yml.tmpl" ''
    use_default_settings: true
    general:
      instance_name: "searxng"
    server:
      secret_key: "SEARXNG_SECRET_PLACEHOLDER"
      limiter: false
      image_proxy: true
    search:
      safe_search: 0
      autocomplete: "duckduckgo"
  '';

  settingsPath = "/run/searxng/settings.yml";
in
{
  sops.secrets.searxng_secret_key = {
    sopsFile = ../secrets/searxng.yaml;
  };

  systemd.services."arion-searxng".preStart = ''
    mkdir -p /run/searxng
    secret=$(cat ${config.sops.secrets.searxng_secret_key.path})
    sed "s/SEARXNG_SECRET_PLACEHOLDER/$secret/" ${settingsTemplate} > ${settingsPath}
    chmod 600 ${settingsPath}
  '';

  virtualisation.arion.projects.searxng.settings = {
    project.name = "searxng";

    services.searxng.service = {
      image = "docker.io/searxng/searxng:latest";
      ports = [ "8080:8080" ];
      volumes = [ "${settingsPath}:/etc/searxng/settings.yml:ro" ];
      restart = "unless-stopped";
    };
  };
}
