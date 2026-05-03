{ modulesPath, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    # Modules
    ../../modules/utils.nix
    ../../modules/users.nix
    ../../modules/ssh.nix
    ../../modules/fail2ban.nix
    ../../modules/docker.nix
    ../../modules/neovim.nix
    ../../modules/node_exporter.nix
    ../../modules/common.nix
    ../../modules/ddns.nix
    ../../modules/caddy.nix
  ];

  networking.hostName = "nixos-caddy";

  age.secrets.cf-token = {
      file = ../../secrets/cf-token.age;
      owner = "docker";
  };
}
