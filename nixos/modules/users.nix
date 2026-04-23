{ 
  config,
  lib,
  pkgs,
  ...
}: {
  users.users = {
    alex = {
      isNormalUser = true;
      extraGroups = [
        "wheel"   # sudo
        "docker"  # docker access
      ];
      uid = 1001;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkMYwuNdqWYMYnW/xb5cqJWmn+0+vkwfJ7iLJjtAag0 alexborrazasm@gmail.com"
      ];
    };
    nario = {
      isNormalUser = true;
      extraGroups = [
        "wheel"   # sudo
        "docker"  # docker access
      ];
      uid = 1002;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB3IqxBfuCloPHqOvbr7k2yXBy01H3PMMPggeCwerZCR mario.l.a3094@gmail.com"
      ];
    };
  };

  # Sudo without password
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

}
