{ 
  config,
  lib,
  pkgs,
  ...
}: {
  services.openssh = {
    enable = true;

    hostKeys = [{
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];

    settings = {
      # Security basics
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      ChallengeResponseAuthentication = false;

      # Only key-based auth
      PubkeyAuthentication = true;

      # Reduce attack surface
      X11Forwarding = false;
      AllowTcpForwarding = "no";
      AllowAgentForwarding = false;

      # QoL
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
    };
    extraConfig = ''
      DenyUsers docker
    '';

  };

}
