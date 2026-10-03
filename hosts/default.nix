let
  config = let
    serviceConfigA = {
      "goobers.cloud" = 8084;
      "meower.fyi" = 8008;

      "search.goobers.cloud" = 8080;
      "redlib.goobers.cloud" = 8082;
      "invidious.goobers.cloud" = 8083;
      "sable.goobers.cloud" = 8085;
      "ntfy.goobers.cloud" = 8086;
    };

    serviceConfigB = {
      "git.goobers.cloud" = 8087;
    };
  in {
    inherit serviceConfigA serviceConfigB;
    servicePortsA = [ 53 ] ++ builtins.attrValues serviceConfigA;
    servicePortsB = [ 8088 ] ++ builtins.attrValues serviceConfigB;
  };

  args = { inherit self config; };

  self = {
    local = (import ./local) args;
    # de24fire = (import ./de24fire) args;
    pfCloud = (import ./pfCloud) args;
    delska = (import ./delska) args;
  };
in
self
