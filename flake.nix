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
          devShells.default =
            let
              inherit (pkgs) lib writeShellScriptBin;
              inherit (lib) getExe;
              secretsOptions = import ./nix/options.nix { inherit lib; };
              defaultSopsKeyFile = secretsOptions.options.secrets.sopsKeyFile.default;
              tte = inputs'.terminaltexteffects.packages.default;
            in
            pkgs.mkShell {
              shellHook = ''
                echo "*** Run the 'secrets-menu' command ***" | tte --frame-rate 300 wipe
              '';

              packages = with pkgs; [
                age
                diffutils
                gum
                jq
                mkpasswd
                sops
                tte
                wl-clipboard
                yq-go

                (writeShellScriptBin "ensure-system-key-exists" (
                  builtins.readFile (
                    pkgs.replaceVars ./.scripts/ensure-system-key-exists {
                      systemKeyFile = defaultSopsKeyFile;
                      age = getExe pkgs.age;
                    }
                  )
                ))

                (writeShellScriptBin "create-system-key" (
                  builtins.readFile (
                    pkgs.replaceVars ./.scripts/create-system-key {
                      gum = getExe pkgs.gum;
                      age = getExe pkgs.age;
                      ageKeygen = "${pkgs.age}/bin/age-keygen";
                    }
                  )
                ))

                (writeShellScriptBin "set-hashed-password" (
                  builtins.readFile (
                    pkgs.replaceVars ./.scripts/set-hashed-password {
                      gum = getExe pkgs.gum;
                      mkpasswd = getExe pkgs.mkpasswd;
                      sops = getExe pkgs.sops;
                      yq = getExe pkgs.yq-go;
                      jq = getExe pkgs.jq;
                    }
                  )
                ))

                (writeShellScriptBin "extract-pub-key" (
                  builtins.readFile (
                    pkgs.replaceVars ./.scripts/extract-pub-key {
                      sshKeygen = "${pkgs.openssh}/bin/ssh-keygen";
                    }
                  )
                ))

                (writeShellScriptBin "print-secret" (
                  builtins.readFile (
                    pkgs.replaceVars ./.scripts/print-secret {
                      sops = getExe pkgs.sops;
                    }
                  )
                ))

                (writeShellScriptBin "list-secrets" (
                  builtins.readFile (
                    pkgs.replaceVars ./.scripts/list-secrets {
                      sops = getExe pkgs.sops;
                      yq = getExe pkgs.yq-go;
                    }
                  )
                ))

                (writeShellScriptBin "set-secret" (
                  builtins.readFile (
                    pkgs.replaceVars ./.scripts/set-secret {
                      sops = getExe pkgs.sops;
                      gum = getExe pkgs.gum;
                      jq = getExe pkgs.jq;
                      yq = getExe pkgs.yq-go;
                    }
                  )
                ))

                (writeShellScriptBin "remove-secret" (
                  builtins.readFile (
                    pkgs.replaceVars ./.scripts/remove-secret {
                      sops = getExe pkgs.sops;
                      gum = getExe pkgs.gum;
                      yq = getExe pkgs.yq-go;
                    }
                  )
                ))

                (writeShellScriptBin "secrets-menu" (
                  builtins.readFile (
                    pkgs.replaceVars ./.scripts/secrets-menu {
                      gum = getExe pkgs.gum;
                      wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
                      sops = getExe pkgs.sops;
                    }
                  )
                ))

                (writeShellScriptBin "generate-ssh-key" (
                  builtins.readFile (
                    pkgs.replaceVars ./.scripts/generate-ssh-key {
                      gum = getExe pkgs.gum;
                      sshKeygen = "${pkgs.openssh}/bin/ssh-keygen";
                      sops = getExe pkgs.sops;
                      jq = getExe pkgs.jq;
                      yq = getExe pkgs.yq-go;
                    }
                  )
                ))

                (writeShellScriptBin "deploy-pub-key" (
                  builtins.readFile (
                    pkgs.replaceVars ./.scripts/deploy-pub-key {
                      gum = getExe pkgs.gum;
                      sshCopyId = "${pkgs.openssh}/bin/ssh-copy-id";
                    }
                  )
                ))
              ];
            };

          formatter = pkgs.nixfmt;
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
