{ 
  config,
  lib, 
  pkgs, 
  ... 
}: {
  services.nginx = {
    enable = true;
    virtualHosts."default" = {
      default = true;
      locations."/" = {
        return = "200 'I am ${config.networking.hostName}\n'";
        extraConfig = "add_header Content-Type text/plain;";
      };
      locations."/health" = {
        return = "200 'ok\n'";
        extraConfig = "add_header Content-Type text/plain;";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}