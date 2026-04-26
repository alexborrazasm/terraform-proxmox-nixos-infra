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

  in {
    # nixos-anywhere
    nixosConfigurations.caddy = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit disko inputs; };
      modules = caddyModules;
    };

    nixosConfigurations.host1 = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit disko inputs; };
      modules = host1Modules;
    };

    nixosConfigurations.host2 = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit disko inputs; };
      modules = host2Modules;
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
          };
        imports = host1Modules;
      };

      host2 = { name, nodes, pkgs, ...}: {
        deployment = {
            targetHost = "10.60.60.12";
        };
        imports = host2Modules;
      };

    };
  };
}
