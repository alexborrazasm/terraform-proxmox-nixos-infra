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
    caddyModules = [
      disko.nixosModules.disko
      agenix.nixosModules.default
      ./hosts/caddy/default.nix
    ];
  in {
    # nixos-anywhere
    nixosConfigurations.caddy = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit disko inputs; };
      modules = caddyModules;
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
    };
  };
}