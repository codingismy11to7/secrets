{
  pkgs,
  lib,
  inputs',
  ...
}:
let
  inherit (lib) getExe;
  secretsOptions = import ./options.nix { inherit lib; };
  defaultSopsKeyFile = secretsOptions.options.secrets.sopsKeyFile.default;
  tte = inputs'.terminaltexteffects.packages.default;
  inherit (pkgs) writeShellScriptBin;
in
pkgs.mkShell {
  shellHook = ''
    echo "*** Run the 'secrets-menu' command ***" | ${getExe tte} --frame-rate 300 wipe
  '';

  packages = with pkgs; [
    age
    diffutils
    gum
    jq
    mkpasswd
    sops
    wl-clipboard
    xdg-utils
    yq-go

    (writeShellScriptBin "create-system-key" (
      builtins.readFile (
        pkgs.replaceVars ../.scripts/create-system-key {
          gum = getExe pkgs.gum;
          age = getExe pkgs.age;
          ageKeygen = "${pkgs.age}/bin/age-keygen";
          sops = getExe pkgs.sops;
        }
      )
    ))

    (writeShellScriptBin "deploy-pub-key" (
      builtins.readFile (
        pkgs.replaceVars ../.scripts/deploy-pub-key {
          gum = getExe pkgs.gum;
          sshCopyId = "${pkgs.openssh}/bin/ssh-copy-id";
        }
      )
    ))

    (writeShellScriptBin "ensure-system-key-exists" (
      builtins.readFile (
        pkgs.replaceVars ../.scripts/ensure-system-key-exists {
          systemKeyFile = defaultSopsKeyFile;
          age = getExe pkgs.age;
        }
      )
    ))

    (writeShellScriptBin "extract-pub-key" (
      builtins.readFile (
        pkgs.replaceVars ../.scripts/extract-pub-key {
          sshKeygen = "${pkgs.openssh}/bin/ssh-keygen";
        }
      )
    ))

    (writeShellScriptBin "generate-ssh-key" (
      builtins.readFile (
        pkgs.replaceVars ../.scripts/generate-ssh-key {
          gum = getExe pkgs.gum;
          sshKeygen = "${pkgs.openssh}/bin/ssh-keygen";
          sops = getExe pkgs.sops;
          jq = getExe pkgs.jq;
          yq = getExe pkgs.yq-go;
        }
      )
    ))

    (writeShellScriptBin "list-secrets" (
      builtins.readFile (
        pkgs.replaceVars ../.scripts/list-secrets {
          sops = getExe pkgs.sops;
          yq = getExe pkgs.yq-go;
        }
      )
    ))

    (writeShellScriptBin "print-secret" (
      builtins.readFile (
        pkgs.replaceVars ../.scripts/print-secret {
          sops = getExe pkgs.sops;
        }
      )
    ))

    (writeShellScriptBin "remove-secret" (
      builtins.readFile (
        pkgs.replaceVars ../.scripts/remove-secret {
          sops = getExe pkgs.sops;
          gum = getExe pkgs.gum;
          yq = getExe pkgs.yq-go;
        }
      )
    ))

    (writeShellScriptBin "secrets-menu" (
      builtins.readFile (
        pkgs.replaceVars ../.scripts/secrets-menu {
          gum = getExe pkgs.gum;
          wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
          sops = getExe pkgs.sops;
          jq = getExe pkgs.jq;
          yq = getExe pkgs.yq-go;
          xdgOpen = "${pkgs.xdg-utils}/bin/xdg-open";
        }
      )
    ))

    (writeShellScriptBin "set-hashed-password" (
      builtins.readFile (
        pkgs.replaceVars ../.scripts/set-hashed-password {
          gum = getExe pkgs.gum;
          mkpasswd = getExe pkgs.mkpasswd;
          sops = getExe pkgs.sops;
          yq = getExe pkgs.yq-go;
          jq = getExe pkgs.jq;
        }
      )
    ))

    (writeShellScriptBin "set-secret" (
      builtins.readFile (
        pkgs.replaceVars ../.scripts/set-secret {
          sops = getExe pkgs.sops;
          gum = getExe pkgs.gum;
          jq = getExe pkgs.jq;
          yq = getExe pkgs.yq-go;
        }
      )
    ))
  ];
}