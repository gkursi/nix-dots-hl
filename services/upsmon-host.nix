machine: { pkgs, ... }:
let
  passwd = pkgs.writeText "ups-passwd.txt" "meow";
in
{
  # ups : nutdrv_qx
  power.ups = {
    enable = true;
    mode = "standalone";
    # section: The upsd UPS declarations: ups.conf
    # this UPS device is named UPS-1.
    ups."UPS-1" = {
      description = "digitus 900w";

      # driver name from https://networkupstools.org/stable-hcl.html
      driver = "nutdrv_qx";
      port = "auto";

      directives = [
        "ondelay = 360"
        "offdelay = 120"
        "pollfreq = 10"
      ];
    };

    upsd = {
      listen = [
        {
          address = "0.0.0.0";
          port = 3493;
        }
        {
          address = "::1";
          port = 3493;
        }
      ];
    };

    users."admin" = {
      passwordFile = "${passwd}";
      upsmon = "primary";
    };
  };
}
