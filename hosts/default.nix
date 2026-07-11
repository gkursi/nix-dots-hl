{
  box-a = {
    target = "invalid-address-change-me";
    services = [ "searxng" ];
  };

  box-b = {
    target = "invalid-address-change-me";
    services = [ "nginx" ];
    tags = [ "public" ];
  };
}
