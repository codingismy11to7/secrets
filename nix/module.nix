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
        unixPassword = mkIf cfg.users.enable {
          neededForUsers = true;
        };
        unixRootPassword = mkIf cfg.users.enable {
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

    environment.sessionVariables.SOPS_AGE_KEY_FILE = cfg.sopsKeyFile;

    users = mkIf cfg.users.enable {
      mutableUsers = false;
      users = {
        root.hashedPasswordFile = config.sops.secrets.unixRootPassword.path;
        ${cfg.username}.hashedPasswordFile = config.sops.secrets.unixPassword.path;
        ${cfg.username}.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxJhslVg1p7z/RcbMefJHoyyazS0c91U1MKBgVQrtuy 2025-12-20" # managed by extract-pub-key
        ];
      };
    };
  };
}
