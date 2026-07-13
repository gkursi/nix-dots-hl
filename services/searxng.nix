machine:

{ config, ... }:
{
  sops.secrets.searxng_secret_key = {
    sopsFile = ../secrets/searxng.yaml;
  };

  sops.templates."searxng-settings.yml".content = ''
    use_default_settings: true
    general:
      instance_name: "searxng"
    server:
      secret_key: "${config.sops.placeholder.searxng_secret_key}"
      limiter: false
      image_proxy: true
    search:
      safe_search: 0
      autocomplete: "duckduckgo"
  '';

  virtualisation.arion.projects.searxng.settings = {
    services.searxng.service = {
      image = "docker.io/searxng/searxng:latest";
      ports = [ "8080:8080" ];
      volumes = [ "${config.sops.templates."searxng-settings.yml".path}:/etc/searxng/settings.yml:ro" ];
      restart = "unless-stopped";
    };
  };
}
