{
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}: {
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
  ];

  # Set hostname
  networking.hostName = "caddy";
  
  services.qemuGuest.enable = true;
  
  # Enable cloud-init service
  services.cloud-init.enable = true;

  # Enable network configuration via cloud-init
  services.cloud-init.network.enable = true;

  # Set systemd-networkd
  networking.useNetworkd = true;

  environment.systemPackages = with pkgs; [
    cloud-utils
  ];
  
  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "@wheel" ];
    max-jobs = "auto";
    cores = 0;
    auto-optimise-store = true;
  };

  networking.firewall = {
    enable = true;
    #allowedTCPPorts = [ 80 443 ];
    #allowedUDPPortRanges = [
    #  { from = 4000; to = 4007; }
    #  { from = 8000; to = 8010; }
    #];
  };
  
  # Do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    RuntimeMaxUse=200M
    MaxRetentionSec=14day
  '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set your time zone
  time.timeZone = "Europe/Madrid";
  
  # Select internationalization properties
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Configure console keymap
  console.keyMap = "us";

  system.stateVersion = "25.11";
}