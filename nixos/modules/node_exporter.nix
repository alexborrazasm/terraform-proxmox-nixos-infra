{
  config,
  lib,
  pkgs,
  ...
}: {
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    enabledCollectors = [ "systemd" "cpu" "meminfo" "diskstats" "netdev" ];
  };
}