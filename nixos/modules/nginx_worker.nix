{
  config,
  lib,
  pkgs,
  ...
}:
let
  indexFiles = {
    "nixos-worker1" = ./nginx-indexes/index1.html;
    "nixos-worker2" = ./nginx-indexes/index2.html;
    "nixos-worker3" = ./nginx-indexes/index3.html;
  };

  webRoot = pkgs.runCommand "worker-webroot" {} ''
    mkdir -p $out
    cp ${indexFiles.${config.networking.hostName}} $out/index.html
  '';
in
{
  services.nginx = {
    enable = true;
    virtualHosts."default" = {
      default = true;
      root = webRoot;
      locations."/" = {
        index = "index.html";
        extraConfig = "charset utf-8;";
      };
      locations."/health" = {
        return = "200 'ok\n'";
        extraConfig = "add_header Content-Type text/plain;";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}