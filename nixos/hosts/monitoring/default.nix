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
    ../../modules/grafana.nix
    ../../modules/prometheus.nix
  ];

  networking.hostName = "monitoring";
}
