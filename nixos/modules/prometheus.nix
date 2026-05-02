{ ... }:
{
  services.prometheus = {
    enable = true;
    port = 9090;

    retentionTime = "15d";

    globalConfig = {
      scrape_interval = "5s";
    };

    scrapeConfigs = [
      {
        job_name = "node_exporters";
        static_configs = [{
          targets = [
            "10.60.60.1:9100"
            "10.60.60.10:9100"
            "10.60.60.11:9100"
            "10.60.60.12:9100"
            "10.60.60.13:9100"
            "10.60.60.14:9100"
          ];
        }];
      }
      {
        job_name = "caddy";
        static_configs = [{
          targets = [ "10.60.60.10:2019" ];
        }];
      }
    ];
  };
}