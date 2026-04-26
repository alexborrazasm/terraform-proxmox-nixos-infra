{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    colmena.url = "github:zhaofengli/colmena";
    agenix.url = "github:ryantm/agenix";
    
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, colmena, disko, agenix, ... }@inputs:
  let
    system = "x86_64-linux";
  
    generalModules = [
      disko.nixosModules.disko
      agenix.nixosModules.default
    ];
  
    caddyModules = [
      ./hosts/caddy
    ] ++ generalModules;

    host1Modules = [
      ./hosts/host1
    ] ++ generalModules;

    host2Modules = [
      ./hosts/host2
    ] ++ generalModules;

    host3Modules = [
      ./hosts/host3
    ] ++ generalModules;

  in {
    # nixos-anywhere

    nixosConfigurations = {
      
      caddy = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit disko inputs; };
        modules = caddyModules;
      };

      host1 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit disko inputs; };
        modules = host1Modules;
      };

      host2 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit disko inputs; };
        modules = host2Modules;
      };

      host3 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit disko inputs; };
        modules = host3Modules;
      };

    };

    colmenaHive = colmena.lib.makeHive self.outputs.colmena;
    colmena = {
      meta = {
        nixpkgs = import nixpkgs { inherit system; };
        specialArgs = { inherit disko inputs; };
      };

      caddy = { name, nodes, pkgs, ... }: {
        deployment = {
          targetHost = "10.60.60.10";
          targetUser = builtins.getEnv "USER";

          # You can build on the target machine
          # buildOnTarget = true;
        };
        imports = caddyModules;
      };

      host1 = { name, nodes, pkgs, ...}: {
        deployment = {
          targetHost = "10.60.60.11";
          targetUser = builtins.getEnv "USER";
        };
        imports = host1Modules;
      };

      host2 = { name, nodes, pkgs, ...}: {
        deployment = {
          targetHost = "10.60.60.12";
          targetUser = builtins.getEnv "USER";
        };
        imports = host2Modules;
      };

      host3 = { name, nodes, pkgs, ...}: {
        deployment = {
          targetHost = "10.60.60.13";
          targetUser = builtins.getEnv "USER";
        };
        imports = host3Modules;  
      };

    };
  };
}
