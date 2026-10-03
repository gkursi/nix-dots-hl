{
  bindAddrs,
  masters,
}:
{ lib, config, ... }:
{
  sops.secrets = {
    bind-slave-rndc.sopsFile = ../secrets/bind-slave.yaml;
  };

  system.activationScripts.chown-bind-slave = {
    deps = [ "sops-install-secrets" ];
    text = ''
      chown 1000:1000 ${config.sops.templates."bind-master-named.conf".path}
    '';
  };

  sops.templates."bind-master-named.conf" = {
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
        allow-new-zones yes;
        catalog-zones { zone "catalog.home.arpa" default-masters { 192.168.0.1; }; };
        rate-limit { responses-per-second 10; };
        minimal-any yes;
        hostname none;
      };

      server ::/0 { bogus yes; };

      key "rndc" {
        algorithm hmac-sha256;
        secret "${config.sops.placeholder.bind-slave-rndc}";
      };

      controls {
        inet 127.0.0.1 port 953
        allow { 127.0.0.1; } keys { "rndc"; };
      };

      view "authoritative" {
        recursion no;

        match-clients { any; };
        allow-query { any; };
        allow-query-cache { none; };
        allow-transfer { none; };

        zone "catalog.home.arpa" {
          type slave;
          file "/bind/var/catalog.home.arpa.db";
          masters { 192.168.0.1; };
          allow-query { 192.168.0.0/16; };
        };
      };
    '';
  };

  virtualisation.arion.projects.ns-slave.settings = {
    services.slave.service = {
      image = "11notes/bind:9";
      command = [ "slave" ];
      environment = {
        TZ = "Europe/Riga";
        BIND_MASTERS = lib.concatMapStrings (m: "${m};") masters;
      };
      ports = lib.concatMap (bindAddr: [
        "${bindAddr}:53:53/udp"
        "${bindAddr}:53:53/tcp"
      ]) bindAddrs;
      sysctls = { "net.ipv4.ip_unprivileged_port_start" = 53; };
      volumes = [
        "etc:/bind/etc"
        "var:/bind/var"
        "${config.sops.templates."bind-master-named.conf".path}:/bind/etc/named.conf"
      ];
      restart = "always";
    };

    docker-compose.volumes = {
      etc = { };
      var = { };
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
