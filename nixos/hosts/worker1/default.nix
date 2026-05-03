{ modulesPath, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    # Modules
    ../../modules/utils.nix
    ../../modules/users.nix
    ../../modules/ssh.nix
    ../../modules/fail2ban.nix
    ../../modules/neovim.nix
    ../../modules/node_exporter.nix
    ../../modules/common.nix
    ../../modules/nginx_worker.nix
  ];

  networking.hostName = "nixos-worker1";
}
