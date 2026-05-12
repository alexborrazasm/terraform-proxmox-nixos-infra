# hostkeys

Pre-generated SSH host keys for each NixOS host. Used by [agenix](https://github.com/ryantm/agenix) to encrypt secrets before first boot.

## Why pre-generate

agenix encrypts secrets against a host's public SSH key. If the key were generated randomly at boot, every reinstall would invalidate all encrypted secrets. Pre-generating guarantees the key is stable across reinstalls.

`deploy-new-host.sh` generates a keypair here if one doesn't exist yet, then copies it to the target host during provisioning via `nixos-anywhere`.

## Structure

```
hostkeys/
└── <hostname>/
    └── etc/ssh/
        ├── ssh_host_ed25519_key      # private key — keep secret, do not commit
        └── ssh_host_ed25519_key.pub  # public key — add to nixos/secrets/secrets.nix
```

## Adding a new host

`deploy-new-host.sh` handles key generation automatically. To get the public key for `secrets.nix`:

```bash
cat nixos/hostkeys/<hostname>/etc/ssh/ssh_host_ed25519_key.pub
```
