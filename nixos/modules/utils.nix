{ 
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # core
    curl
    wget
    gitMinimal
    rsync
    tree
    jq

    # monitoring
    htop
    btop
    iotop
    iftop
    strace
    ltrace
    lsof

    # modern replacements
    eza        # ls replacement
    bat        # cat replacement
    fd         # find replacement
    ripgrep    # grep replacement
    dust       # du replacement

    # archives
    zip
    xz
    unzip
    p7zip
    unrar

    # networking tools
    dnsutils  # `dig` + `nslookup`
    nmap
    traceroute
    net-tools
    tcpdump
    socat
    inetutils

    # misc
    rlwrap
    fastfetch

    tmux
  ];

  # Enable direnv daemon with nix-direnv integration
  programs.direnv = {
    enable = true;
  };

  environment.shellAliases = {
    l   = "eza --group-directories-first -g";
    ll  = "eza -l --group-directories-first -g";
    la  = "eza -a --group-directories-first -g";
    lla = "eza -la --group-directories-first -g";
    ls  = "eza --group-directories-first -g";
    cat = "bat -pP";
    neofetch = "fastfetch";
    ncg  = "nix-collect-garbage -d";
    ncgk = "sudo nix-collect-garbage -d";
  };
}
