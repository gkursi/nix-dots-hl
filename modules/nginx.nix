{
  hosts,
  useTls ? false,
}:
{ ... }:
let
  proxyLocalPort = bind: port: {
    listen = [
      {
        addr = bind;
        port = port;
        ssl = false;
      }
    ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";

      extraConfig = ''
        proxy_set_header X-Forwarded-Proto https;
      '';
    };
  };

  proxyToPort =
    srcAddr: dstAddr: dstPort:
    let
      enableTls = useTls;
    in
    {
      forceSSL = enableTls;
      enableACME = enableTls;
      # kTLS = enableTls;

      listenAddresses = [ srcAddr ];

      locations."/" = {
        proxyPass = "${dstAddr}:${toString dstPort}";
      };
    };

  # for each hostname, proxies requests on the incoming port to the given local port
  mkUpstreamProxy =
    address: hosts: builtins.mapAttrs (hostname: port: proxyLocalPort address port) hosts;
  mkMergeProxy =
    srcAddress: dstAddress: hosts:
    builtins.mapAttrs (hostname: port: proxyToPort srcAddress dstAddress port) hosts;
in
{
  services.nginx = {
    enable = true;

    virtualHosts = hosts {
      upstream = mkUpstreamProxy;
      merge = mkMergeProxy;
    };

    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    appendHttpConfig = ''
      map $http_upgrade $connection_upgrade {
          default upgrade;
          \'\'      close;
      }
      log_format hostdbg '[$host] [$http_host] [$http_x_forwarded_host]';
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
