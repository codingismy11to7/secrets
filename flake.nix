{
  description = "Secrets and integrations for them";

  inputs = {
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    terminaltexteffects = {
      url = "github:ChrisBuilds/terminaltexteffects";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      systems,
      terminaltexteffects,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import an internal flake module: ./other.nix
        # To import an external flake module:
        #   1. Add foo to inputs
        #   2. Add foo as a parameter to the outputs function
        #   3. Add here: foo.flakeModule
      ];
      systems = import systems;
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          devShells.default = import ./nix/devshell.nix {
            inherit pkgs inputs';
            inherit (pkgs) lib;
          };

          formatter = pkgs.nixfmt;
        };

      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
        nixosModules.default = {
          imports = [
            ./nix/nixos.nix
            inputs.sops-nix.nixosModules.sops
          ];
        };

        homeManagerModules.default = {
          imports = [
            ./nix/home-manager.nix
            inputs.sops-nix.homeManagerModules.sops
          ];
        };
      };
    };
}
