{
  boxA = {
    target = "192.168.8.100";

    services = {
      searxng = {
        drive = 0;
      };

      i2p = {
        drive = 0;
      };

      glance = {
        drive = 0;
      };

      pihole = {
        drive = 0;
      };
    };

    drives = [ "/mnt/container" ];
    tags = [ "private" ];
  };
}
