{ lib, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  services.qemuGuest.enable = true;

  services.cloud-init.enable = true;
  services.cloud-init.network.enable = true;

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

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  networking.firewall.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    RuntimeMaxUse=200M
    MaxRetentionSec=14day
  '';

  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  system.stateVersion = "25.11";
}
