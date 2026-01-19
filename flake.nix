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
  };

  outputs =
    inputs@{ flake-parts, systems, ... }:
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
          devShells.default =
            let
              inherit (pkgs) lib writeShellScriptBin;
              inherit (lib) getExe;
              secretsOptions = import ./nix/options.nix { inherit lib; };
              defaultSopsKeyFile = secretsOptions.options.secrets.sopsKeyFile.default;
            in
            pkgs.mkShell {
              packages = with pkgs; [
                age
                sops

                (writeShellScriptBin "ensure-system-key-exists" (
                  builtins.readFile (
                    pkgs.replaceVars ./.scripts/ensure-system-key-exists {
                      age = getExe pkgs.age;
                      systemKeyFile = defaultSopsKeyFile;
                    }
                  )
                ))
              ];
            };

          formatter = pkgs.nixfmt;

          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.

        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
        nixosModules.default = {
          imports = [
            ./nix/module.nix
            inputs.sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
