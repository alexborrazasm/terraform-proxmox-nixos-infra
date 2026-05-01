{ 
  config,
  lib,
  pkgs,
  ...
}: {

  services.caddy = {
    enable = true;
    configFile = ./caddy-config/Caddyfile;
    openFirewall = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-Olz4W84Kiyldy+JtbIicVCL7dAYl4zq+2rxEOUTObxA=";
    };
  };
  
  # For Grafana metrics collection
  networking.firewall.allowedTCPPorts = [ 2019 ];

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.cf-token.path;
}
