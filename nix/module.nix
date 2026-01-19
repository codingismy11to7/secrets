{
  config,
  lib,
  ...
}:
with builtins;
let
  inherit (lib) mkIf;

  cfg = config.secrets;
in
{
  imports = [ ./options.nix ];

  config = mkIf cfg.enable {
    sops = {
      age.keyFile = cfg.sopsKeyFile;
      defaultSopsFile = path { path = ../secrets.yaml; };

      secrets = {
        githubNixToken = { };
        sshPrivKey = {
          path = "${config.home.homeDirectory}/.ssh/id_ed25519";
          mode = "0600";
        };
        unixPassword = mkIf cfg.user.enable {
          neededForUsers = true;
        };
        unixRootPassword = mkIf cfg.user.enable {
          neededForUsers = true;
        };
      };

      templates."nix.conf".content = ''
        access-tokens = github.com=${config.sops.placeholder.githubNixToken}
      '';
    };

    nix.extraOptions = ''
      !include ${config.sops.templates."nix.conf".path}
    '';

    home.sessionVariables.SOPS_AGE_KEY_FILE = ageKeyFile;

    users = mkIf cfg.user.enable {
      mutableUsers = false;
      users.root.hashedPasswordFile = config.sops.secrets.unixRootPassword.path;
      users.${cfg.username}.hashedPasswordFile = config.sops.secrets.unixPassword.path;
    };
  };
}
