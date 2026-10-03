{
  listenAddress,
  slaves,
  drive,
}:
{ lib, config, ... }:
{
  sops.secrets = let
    secret_file = ../secrets/bind.yaml;
  in {
    bind-rndc.sopsFile = secret_file;
    bind-root.sopsFile = secret_file;
  };

  system.activationScripts.chown-bind = {
    text = ''
      chown 1000:1000 ${config.sops.templates."bind-named.conf".path}
    '';
  };

  sops.templates."bind-named.conf" = {
    content = ''
      options {
        listen-on { any; };
        directory "/bind/etc";
        recursion no;
        version "0.0";
        auth-nxdomain no;
        max-cache-size 0;
        dnssec-validation no;
        notify explicit;
        allow-transfer { 192.168.0.2; 192.168.0.5; };
        also-notify { 192.168.0.2; 192.168.0.5; };
        allow-new-zones yes;
        dnssec-policy default;
      };

      server ::/0 { bogus yes; };

      key "rndc" {
        algorithm hmac-sha256;
        secret "${config.sops.placeholder.bind-rndc}";
      };

      key "catalog.home.arpa" {
        algorithm hmac-sha256;
        secret "${config.sops.placeholder.bind-root}";
      };

      controls {
        inet 127.0.0.1 port 953
        allow { 127.0.0.1; } keys { "rndc"; };
      };

      statistics-channels {
        inet 0.0.0.0 port 8053;
      };

      acl acl-rfc1918 {
        127.0.0.1;
        10.0.0.0/8;
        172.16.0.0/12;
        192.168.0.0/16;
      };

      view "authoritative" {
        include "/bind/etc/keys.conf";

        match-clients { acl-rfc1918; };
        allow-query { acl-rfc1918; };
        zone "catalog.home.arpa" { type master; file "/bind/var/catalog.home.arpa.db"; allow-update { key catalog.home.arpa.; 127.0.0.1; }; };
      };
    '';
  };

  virtualisation.arion.projects.ns-master.settings = {
    services.master.service = {
      image = "11notes/bind:9";
      command = [ "master" ];
      environment = {
        TZ = "Europe/Zurich";
        BIND_SLAVES = lib.concatMapStrings (s: "${s};") slaves;
      };
      ports = [
        "${listenAddress}:53:53/udp"
        "${listenAddress}:53:53/tcp"
      ];
      sysctls = { "net.ipv4.ip_unprivileged_port_start" = 53; };
      volumes = [
        "${drive}/bind/etc:/bind/etc"
        "${drive}/bind/var:/bind/var"
        "${config.sops.templates."bind-named.conf".path}:/bind/etc/named.conf"
      ];
      restart = "always";
    };

    docker-compose.volumes = {
      etc = { };
      var = { };
    };
  };
}
