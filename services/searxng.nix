machine:
{ config, ... }:
{
  sops.secrets.searxng_secret_key = {
    sopsFile = ../secrets/searxng.yaml;
  };

  sops.templates."searxng-settings.yml".content = ''
    use_default_settings: true

    general:
      debug: false
      instance_name: "meowxng"

    server:
      secret_key: "${config.sops.placeholder.searxng_secret_key}"
      limiter: true
      image_proxy: true
      base_url: https://search.goobers.cloud

    search:
      safe_search: 0
      autocomplete: "duckduckgo"
  '';

  virtualisation.arion.projects.searxng.settings = {
    services.searxng.service = {
      image = "docker.io/searxng/searxng:latest";
      ports = [ "127.0.0.1:8080:8080" ];
      volumes = [ "${config.sops.templates."searxng-settings.yml".path}:/etc/searxng/settings.yml:ro" ];
      restart = "unless-stopped";
    };
  };
}
