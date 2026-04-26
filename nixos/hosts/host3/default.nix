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
  ];

  nixpkgs.config.allowUnfree = true;

  # Set hostname
  networking.hostName = "host3";
  
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

  networking.firewall = {
    enable = true;
    #allowedTCPPorts = [ 80 443 ];
    #allowedUDPPortRanges = [
    #  { from = 4000; to = 4007; }
    #  { from = 8000; to = 8010; }
    #];
  };

  system.stateVersion = "25.11";
}
