# terraform-proxmox-nixos-infra
Toy example of a fully reproducible infrastructure on Proxmox using Terraform, 
NixOS and Docker.

# Terraform

Terraform is an infrastructure as code tool that lets you build, change, and 
version infrastructure safely and efficiently.

We use Terraform to define our infrastructure on Proxmox, which includes virtual 
machines, networks and storage. This allows us to easily manage and version our 
infrastructure.

## Installation

```bash
sudo pacman -Syu terraform
```

# NixOS

NixOS is a Linux distribution that uses the Nix package manager to provide
reproducible builds and declarative configuration. We use NixOS to define the
configuration of our virtual machines, which allows us to easily manage and
version our system configuration.

# Docker

Docker provides the ability to package and run an application in a loosely 
isolated environment called a container. The isolation and security let you run 
many containers simultaneously on a given host. Containers are lightweight and 
contain everything needed to run the application, so you don't need to rely on 
what's installed on the host. You can share containers while you work, and be 
sure that everyone you share with gets the same container that works in the 
same way.
