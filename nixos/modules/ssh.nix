{ 
  config,
  lib,
  pkgs,
  ...
}: {
  services.openssh = {
    enable = true;

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
