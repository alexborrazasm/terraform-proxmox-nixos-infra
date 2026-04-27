let
  # Admin Public Keys
  alex = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkMYwuNdqWYMYnW/xb5cqJWmn+0+vkwfJ7iLJjtAag0 alexborrazasm@gmail.com";
  choped = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB3IqxBfuCloPHqOvbr7k2yXBy01H3PMMPggeCwerZCR mario.l.a3094@gmail.com";

  # Host Public Keys
  caddy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbqtejP4F+AiKukV37RglIO3OCyyfURUkziFDRMS4MC root@nixos";

  all_admins = [ alex choped ];
in
{
  "cf-token.age".publicKeys = all_admins ++ [ caddy ];
}