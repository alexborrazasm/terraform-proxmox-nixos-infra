{ 
  config,
  lib,
  pkgs,
  ...
}: let
  docker-manager = pkgs.writeShellScriptBin "docker-manager" (
    builtins.readFile ../scripts/docker-manager.sh
  );
in {
  virtualisation.docker = {
    enable = true;

    autoPrune = {
      enable = true;
      dates = "daily";
      flags = [
        "--all"
        "--force"
        "--filter=until=168h"
      ];
    };

    daemon.settings = {
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "5";
      };
    };
  };

  users.users = {
    docker = {
      isNormalUser = true;
      group = "docker";
      extraGroups = [
        "docker" # docker access
      ];
      uid = 1000;
      home = "/srv/docker";
      createHome = false;
    };
  };
  
  systemd.tmpfiles.rules = [
    # Root directory for Docker Compose projects and service configs
    "d /srv/docker 0775 docker docker -"
    # Web Assets: Persistent storage for static websites and public assets
    "d /srv/www    0775 docker docker -"
  ];
  
  environment.shellAliases = {
    sd = "sudo -u docker -i";
    dcm = "docker-manager";
  };

  environment.systemPackages = [ docker-manager ];

}