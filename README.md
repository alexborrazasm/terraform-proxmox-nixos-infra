# terraform-proxmox-nixos-infra
Toy example of a fully reproducible infrastructure on Proxmox using OpenTofu, 
NixOS and Docker.

# Proxmox VE

[Proxmox Virtual Environment](https://www.proxmox.com/en/) is a complete, 
open-source server management platform for enterprise virtualization. It tightly 
integrates the KVM hypervisor and Linux Containers (LXC), software-defined 
storage and networking functionality, on a single platform. With the integrated 
web-based user interface you can manage VMs and containers, high availability 
for clusters or the integrated disaster recovery 
tools with ease.

In this project is the underlying infrastructure provider, which allows us to 
define our virtual machines, networks and storage using OpenTofu. We use 
Proxmox to host our virtual machines, which run NixOS and Docker.

## Installation

The version of Proxmox used in this project is 9.1, lastest release at the time 
of writing.

After a fresh installation of Proxmox, you can access the web interface at 
`https://<proxmox-ip>:8006`. The default username is `root` and the password is 
the one you set during the installation.

We also need to enable the Proxmox API, which is required for OpenTofu to
communicate with Proxmox. To do this, on the proxmox node terminal, run the 
following commands.

### Create a user and role for OpenTofu:

```bash
pveum role modify TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt VM.GuestAgent.Audit VM.GuestAgent.Unrestricted SDN.Use"
pveum user add terraform-prov@pve --password <password>
pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

### Create an API token for OpenTofu:

```bash
pveum role modify TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt SDN.Use"
pveum user token add terraform-prov@pve terraform-token --privsep 0
```
Output should look like this:
```bash
┌──────────────┬──────────────────────────────────────┐
│ key          │ value                                │
╞══════════════╪══════════════════════════════════════╡
│ full-tokenid │ terraform-prov@pve!terraform-token   │
├──────────────┼──────────────────────────────────────┤
│ info         │ {"privsep":"0"}                      │
├──────────────┼──────────────────────────────────────┤
│ value        │ <YOUR_API_TOKEN>                     │
└──────────────┴──────────────────────────────────────┘
```

Save the `full-tokenid` and `value` in the `.env` file, which will be used by 
OpenTofu to authenticate with the Proxmox API.

# OpenTofu

[OpenTofu](https://opentofu.org/) is an open-source infrastructure as code tool,
fork of Terraform, that lets you build, change, and version infrastructure safely
and efficiently.

We use OpenTofu to define our infrastructure on Proxmox, which includes virtual 
machines, networks and storage. This allows us to easily manage and version our 
infrastructure.

## Installation

On Arch Linux, you can install OpenTofu using the following command:
```bash
sudo pacman -Syu opentofu
```

Other Linux distributions can check the [OpenTofu installation guide](https://opentofu.org/docs/intro/install/) 
for instructions.

## Setup

Before running OpenTofu, you need to create a `.env` file in the `terraform` 
directory. You can copy the `.env.dist` file and fill in the values with your 
Proxmox API credentials, which you obtained in the previous step.

```bash
cd terraform
cp .env.dist .env
set -a; source .env; set +a
tofu init
```

# NixOS

[NixOS](https://nixos.org/) is a Linux distribution that uses the Nix package 
manager to provide reproducible builds and declarative configuration. We use 
NixOS to define the configuration of our virtual machines, which allows us to 
easily manage and version our system configuration.

The NixOS configuration lives in the `nixos/` directory and is structured as a
Nix flake. Each host has its own directory under `nixos/hosts/` with a
`default.nix` (system config), `disk-config.nix` (partition layout via disko)
and `hardware-configuration.nix` (kernel modules and platform). Shared config is
split into reusable modules under `nixos/modules/`.

## Initial deployment with nixos-anywhere

[nixos-anywhere](https://github.com/nix-community/nixos-anywhere) installs NixOS
on a remote machine over SSH from scratch, without needing a NixOS ISO. It works
by booting the target into a temporary in-memory environment (kexec), partitioning
the disk using [disko](https://github.com/nix-community/disko) according to our
`disk-config.nix`, and then installing the full NixOS system defined in our flake.
This lets us turn any Linux machine (including the Debian template created by
OpenTofu) into a NixOS host with a single command.

### Prepare a template

Before the initial deployment, we need a Debian 13 VM with cloud-init support
and SSH access. OpenTofu provisions this automatically. The template only needs:

- SSH access with your public key
- Nix installed (to generate the hardware configuration)

### Install Nix on the template:
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### Get hardware configuration:

Connect to the template VM and run:
```bash
nix-shell -p nixos-install-tools --run "nixos-generate-config --no-filesystems --root /mnt"
cat /mnt/etc/nixos/hardware-configuration.nix
```

Copy the output into `nixos/hosts/<host>/hardware-configuration.nix`. This file
captures kernel modules specific to the VM hardware (QEMU guest, disk controllers, etc).

Example:
```nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
```

All VMs created from the same Proxmox template will share this hardware configuration.

### Deploy NixOS:

From the `nixos/` directory, run nixos-anywhere pointing at the target host:
```bash
cd nixos
nix run github:nix-community/nixos-anywhere -- --flake .#caddy template@<template-ip> -i <path-to-your-ssh-key>
```

nixos-anywhere will partition the disk, install NixOS and reboot. After the reboot
the machine is fully managed by NixOS and SSH access is available with the keys
defined in `nixos/modules/users.nix`.

> **Note:** After the reboot the host key of the machine changes (it is no longer
> the Debian template, it is a fresh NixOS install). SSH will refuse to connect
> with a host key mismatch error. Remove the old entry from your known hosts:
> ```bash
> ssh-keygen -R <host-ip>
> ```

## Subsequent deployments with Colmena

After the initial nixos-anywhere installation, ongoing configuration changes are
deployed using [Colmena](https://github.com/zhaofengli/colmena), a NixOS
deployment tool that applies changes to running machines over SSH without
reinstalling.

```bash
# Build without deploying
nix run github:zhaofengli/colmena -- build

# Deploy to all hosts
nix run github:zhaofengli/colmena -- apply --impure

# Deploy to a specific host
nix run github:zhaofengli/colmena -- apply --on <hostname> --impure
```

Colmena reads the `colmena` output of the flake and deploys to the hosts defined
there. The `targetHost` and `targetUser` for each host are set in `flake.nix`.

### SSH configuration for Colmena

Add an entry for each host in your `~/.ssh/config` so Colmena can reach them
using the correct key:

```
Host <host-ip>
  IdentityFile ~/.ssh/<your-key>
```

## Secrets management with agenix

[agenix](https://github.com/ryantm/agenix) manages secrets by encrypting them
with [age](https://age-encryption.org/) (asymmetric crypto). Encrypted files are
safe to commit to git — only holders of the corresponding private keys can decrypt
them.

### How it works

Each secret is encrypted for a set of public keys defined in `nixos/secrets/secrets.nix`.
At boot, the NixOS agenix module decrypts secrets using the host's SSH host key
(`/etc/ssh/ssh_host_ed25519_key`) and writes the plaintext to `/run/agenix/`
(tmpfs, cleared on reboot). Services read secrets from that path.

#### Access control — `nixos/secrets/secrets.nix`

```nix
let
  alex   = "ssh-ed25519 AAAA...";  # admin public key
  choped = "ssh-ed25519 AAAA...";  # admin public key
  caddy  = "ssh-ed25519 AAAA...";  # host public key (root@nixos)

  all_admins = [ alex choped ];
in
{
  "cf-token.age".publicKeys = all_admins ++ [ caddy ];
}
```

Every key listed can decrypt the secret:
- **Admin keys** — allow admins to edit secrets from their machines
- **Host key** — allows the host to decrypt at activation time (`nixos-rebuild switch`)

The host key is `/etc/ssh/ssh_host_ed25519_key`, generated at first boot. Retrieve
it with:
```bash
ssh root@<host-ip> "cat /etc/ssh/ssh_host_ed25519_key.pub"
```

#### Referencing a secret in a host config

```nix
age.secrets.cf-token = {
  file  = ../../secrets/cf-token.age;  # encrypted blob tracked in git
  owner = "docker";                    # unix owner of the decrypted file
};
```

The decrypted path is available in Nix as `config.age.secrets.cf-token.path`,
which resolves to `/run/agenix/cf-token` at runtime.

### Creating or editing a secret

```bash
cd nixos/secrets

# Create or edit a secret (opens $EDITOR with decrypted content)
nix shell github:ryantm/agenix -- -e <secret-name>.age --identity ~/.ssh/<your-key>
```

agenix reads `secrets.nix` to determine which public keys to encrypt for, so all
listed recipients can decrypt the result.

### Adding a new secret — full workflow

1. Add the entry in `nixos/secrets/secrets.nix`:
   ```nix
   "new-secret.age".publicKeys = all_admins ++ [ host ];
   ```

2. Create the encrypted file:
   ```bash
   cd nixos/secrets
   nix shell github:ryantm/agenix -- -e new-secret.age --identity ~/.ssh/<your-key>
   ```

3. Reference it in the host config (`nixos/hosts/<host>/default.nix`):
   ```nix
   age.secrets.new-secret.file = ../../secrets/new-secret.age;
   ```

4. Use the runtime path in a service:

   **NixOS service** (`owner` = the service user):
   ```nix
   age.secrets.new-secret = {
     file  = ../../secrets/new-secret.age;
     owner = "myservice";
   };

   services.foo.passwordFile = config.age.secrets.new-secret.path;
   # resolves to /run/agenix/new-secret at runtime
   ```

   **Docker Compose** (`owner = "docker"` in the host config):

   The decrypted file at `/run/agenix/new-secret` is owned by the `docker` user.
   Bind-mount it into the container:
   ```yaml
   # /srv/docker/myapp/compose.yml
   services:
     myapp:
       image: myapp:latest
       volumes:
         - /run/agenix/new-secret:/run/secrets/new-secret:ro
       environment:
         SECRET_FILE: /run/secrets/new-secret
   ```

   Or use it as an `env_file` if the secret is in `KEY=value` format:
   ```yaml
   services:
     myapp:
       image: myapp:latest
       env_file:
         - /run/agenix/new-secret
   ```

5. Deploy with Colmena:
   ```bash
   nix run github:zhaofengli/colmena -- apply --on <hostname> --impure
   ```

# Docker

[Docker](https://www.docker.com/) provides the ability to package and run an application in a loosely 
isolated environment called a container. The isolation and security let you run 
many containers simultaneously on a given host. Containers are lightweight and 
contain everything needed to run the application, so you don't need to rely on 
what's installed on the host. You can share containers while you work, and be 
sure that everyone you share with gets the same container that works in the 
same way.
