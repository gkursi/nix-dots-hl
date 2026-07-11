{ pkgs }:
let
  config = pkgs.writeText "nginx.conf" ''
    user nginx;
    worker_processes auto;

    events {
      worker_connections 1024;
    }

    http {
      include       mime.types;
      default_type  application/octet-stream;
      sendfile      on;

      server {
        listen 80;
        server_name search.example.com;

        location / {
          proxy_pass http://127.0.0.1:8888;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
      }
    }
  '';
in
{
  virtualisation.arion.projects.searxng.settings = {
    projectName = "nginx";
    services.nginx.service = {
      image = "docker.io/nginx:alpine";
      ports = [
        "80:80"
        "443:443"
      ];
      volumes = [ "${config}:/etc/nginx/nginx.conf:ro" ];
      restart = "unless-stopped";
    };
  };
}
