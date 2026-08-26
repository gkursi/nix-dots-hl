nginxConfig:
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
    };
  };

  proxyToPort =
    srcAddr: destAddr: port:
    let
      enableTls = nginxConfig.useTls or false;
    in
    {
      forceSSL = enableTls;
      enableACME = enableTls;
      kTLS = enableTls;

      listenAddresses = [ srcAddr ];

      locations."/" = {
        proxyPass = "${destAddr}:${port}";
      };
    };

  # for each hostname, proxies requests on the incoming port to the given local port
  mkUpstreamProxy =
    address: hosts: builtins.mapAttrs (hostname: port: proxyLocalPort address port) hosts;
  mkMergeProxy = address: hosts: builtins.mapAttrs (hostname: port: proxyToPort address port) hosts;
in
{
  services.nginx = {
    enable = true;

    virtualHosts = nginxConfig.hosts {
      upstream = mkUpstreamProxy;
      merge = mkMergeProxy;
    };

    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
  };
}
