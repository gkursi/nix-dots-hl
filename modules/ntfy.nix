ntfy:
{ pkgs, ... }:
let
  cfg = pkgs.writeText "config.yml" "";
  drive = ntfy.drive;
in
{
  virtualisation.arion.projects.ntfy.settings = {
    services.ntfy.service = {
      image = "docker.io/binwiederhier/ntfy";
      ports = [ "127.0.0.1:8086:80" ];
      command = [ "serve" ];
      volumes = [
        "${cfg}:/etc/ntfy/server.yml:ro"
        "${drive}/ntfy/data:/etc/ntfy"
        "${drive}/ntfy/cache:/var/lib/ntfy"
      ];
      environment = {
        NTFY_BASE_URL = "http://ntfy.example.com";
        NTFY_CACHE_FILE = "/var/lib/ntfy/cache.db";
        NTFY_BEHIND_PROXY = "true";
        NTFY_ATTACHMENT_CACHE_DIR = "/var/lib/ntfy/attachments";
        NTFY_UPSTREAM_BASE_URL = "https://ntfy.sh";
        NTFY_WEB_PUSH_FILE = "/var/lib/ntfy/webpush.db";
      };
      restart = "unless-stopped";
    };
  };
}
