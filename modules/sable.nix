sableConfig:
{ pkgs, ... }:
let
  config = pkgs.writeText "sable-config" ''
    {
      "productName": "Sable on goobers.cloud",
      "defaultHomeserver": 0,
      "homeserverList": ["m.gayboi.club"],
      "allowCustomHomeservers": true,
      "elementCallUrl": null,

      "disableAccountSwitcher": false,
      "hideUsernamePasswordFields": false,

      "pushNotificationDetails": {
        "pushNotifyUrl": "https://sygnal.sable.moe/_matrix/push/v1/notify",
        "vapidPublicKey": "BCnS4SbHjeOaqVFW4wjt5xDt_pYIL62qMzKePfYF9fl9PQU14RieIaObh7nLR_9dQf4sykZa-CTrcjkgMIE1mcg",
        "webPushAppID": "moe.sable.app.sygnal",
        "nativePushAppID": "moe.sable.client.android",
        "unifiedPushAppID": "moe.sable.up"
      },

      "themeCatalogBaseUrl": "https://raw.githubusercontent.com/SableClient/themes/main/",
      "themeCatalogApprovedHostPrefixes": ["https://raw.githubusercontent.com/SableClient/themes/"],

      "featuredCommunities": {
        "openAsDefault": false,
        "spaces": [
          "#space:silly.ltd"
        ],
        "rooms": [],
        "servers": ["matrixrooms.info", "mozilla.org", "unredacted.org"]
      },

      "hashRouter": {
        "enabled": false,
        "basename": "/"
      },

      "gifs": {
        "provider": "tenor",
        "proxyUrl": "gifs.sable.moe",
        "tenorApiKey": "AIzaSyCZt6SSh5VgVPzD9fhyzG1DprdPRhtoaR4",
        "klipyApiKey": "pmpZyPifwSulBfELHCbpaOllUfgsjqt9yeImc2XWIcHSWjnAUBw9oueRf4kD5r25",
        "giphyApiKey": "Gc7131jiJuvI7IdN0HZ1D7nh0ow5BU6g"
      }
    }
  '';
in
{
  virtualisation.arion.projects.sable.settings = {
    services.sable.service = {
      image = "ghcr.io/sableclient/sable:latest";
      ports = [ "127.0.0.1:8085:8080" ];
      volumes = [ "${config}:/app/config.json:ro" ];
      restart = "unless-stopped";
    };
  };
}
