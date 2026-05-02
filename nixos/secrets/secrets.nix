let
  # Admin Public Keys
  alex = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkMYwuNdqWYMYnW/xb5cqJWmn+0+vkwfJ7iLJjtAag0 alexborrazasm@gmail.com";
  choped = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB3IqxBfuCloPHqOvbr7k2yXBy01H3PMMPggeCwerZCR mario.l.a3094@gmail.com";

  # Host Public Keys
  caddy      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEDPUTLWQR3mLYStfXLJN42xRZOedGMBgjMuTFfc2cz+ root@caddy";
  monitoring = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ5jOszYkgu5bwjfv7I/defSPkExOVKHiteJV/YPnvkM root@monitoring";

  all_admins = [ alex choped ];
in
{
  "cf-token.age".publicKeys               = all_admins ++ [ caddy ];
  "grafana-admin-password.age".publicKeys = all_admins ++ [ monitoring ];
  "grafana-secret-key.age".publicKeys     = all_admins ++ [ monitoring ];
}
