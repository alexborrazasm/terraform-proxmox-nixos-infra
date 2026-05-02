{ lib, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;
  services.qemuGuest.enable = true;
  
  services.cloud-init = {
    enable = true;
    network.enable = true;
    
    # Override del cloud.cfg for exclude ssh module
    config = ''
      system_info:
        distro: nixos
        network:
          renderers: [ networkd ]
      
      disable_root: false
      preserve_hostname: false
      
      # NO tocar host keys ni authorized_keys
      ssh_deletekeys: false
      ssh_genkeytypes: []
      
      cloud_init_modules:
        - migrator
        - seed_random
        - bootcmd
        - write-files
        - growpart
        - resizefs
        - update_hostname
        - resolv_conf
        - ca-certs
        - rsyslog
        - users-groups
      
      cloud_config_modules:
        - disk_setup
        - mounts
        - set-passwords
        - timezone
        - disable-ec2-metadata
        - runcmd
        # ssh y ssh-import-id removed
      
      cloud_final_modules:
        - scripts-vendor
        - scripts-per-once
        - scripts-per-boot
        - scripts-per-instance
        - scripts-user
        - phone-home
        - final-message
        - power-state-change
        # ssh-authkey-fingerprints y keys-to-console removed
      
      users:
        - root
    '';
  };
  
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
