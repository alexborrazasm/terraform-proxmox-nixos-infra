{ pkgs, config, ... }: {

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.0.0-20240409160914-1f66060875e5" ];
      # Nota: La primera vez que hagas el build, Nix fallará y te dará el hash correcto. 
      # Sustitúyelo aquí cuando te lo dé.
      hash = "sha256-0000000000000000000000000000000000000000000="; 
    };
    configFile = ../../docker/caddy/caddy-container/Caddyfile;
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.cf-token.path;
}
