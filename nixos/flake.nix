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

    worker1Modules = [
      ./hosts/worker1
    ] ++ generalModules;

    worker2Modules = [
      ./hosts/worker2
    ] ++ generalModules;

    worker3Modules = [
      ./hosts/worker3
    ] ++ generalModules;

    monitoringModules = [
      ./hosts/monitoring
    ] ++ generalModules;

  in {
    # nixos-anywhere

    nixosConfigurations = {
      
      caddy = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit disko inputs; };
        modules = caddyModules;
      };

      worker1 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit disko inputs; };
        modules = worker1Modules;
      };

      worker2 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit disko inputs; };
        modules = worker2Modules;
      };

      worker3 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit disko inputs; };
        modules = worker3Modules;
      };

      monitoring = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit disko inputs; };
          modules = monitoringModules;
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

      worker1 = { name, nodes, pkgs, ...}: {
        deployment = {
          targetHost = "10.60.60.11";
          targetUser = builtins.getEnv "USER";
        };
        imports = worker1Modules;
      };

      worker2 = { name, nodes, pkgs, ...}: {
        deployment = {
          targetHost = "10.60.60.12";
          targetUser = builtins.getEnv "USER";
        };
        imports = worker2Modules;
      };

      worker3 = { name, nodes, pkgs, ...}: {
        deployment = {
          targetHost = "10.60.60.13";
          targetUser = builtins.getEnv "USER";
        };
        imports = worker3Modules;  
      };

      monitoring = { name, nodes, pkgs, ...}: {
          deployment = {
              targetHost = "10.60.60.14";
              targetUser = builtins.getEnv "USER";
          };
          imports = monitoringModules;
      };

    };
  };
}
