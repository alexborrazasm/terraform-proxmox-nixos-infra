{ config, ... }:
{
  age.secrets.grafana-admin-password = {
    file  = ../secrets/grafana-admin-password.age;
    owner = "grafana";
  };
  age.secrets.grafana-secret-key = {
    file  = ../secrets/grafana-secret-key.age;
    owner = "grafana";
  };

  services.grafana = {
    enable = true;

    settings = {
      server = {
        http_port = 3000;
        http_addr = "0.0.0.0";
        root_url  = "https://grafana.mariolamasangeriz.net";
      };

      security = {
        admin_password = "$__file{${config.age.secrets.grafana-admin-password.path}}";
        secret_key     = "$__file{${config.age.secrets.grafana-secret-key.path}}";
      };
    };

    dataDir = "/srv/grafana/data";

    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name      = "Prometheus";
            type      = "prometheus";
            url       = "http://localhost:9090";
            isDefault = true;
          }
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}