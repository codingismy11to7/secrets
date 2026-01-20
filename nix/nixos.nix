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
  imports = [
    ./options.nix
    ./github-token.nix
  ];

  config = mkIf cfg.enable {
    sops = {
      age.keyFile = cfg.sopsKeyFile;
      defaultSopsFile = path { path = ../secrets.yaml; };

      secrets = {
        githubNixToken = { };
        unixPassword = mkIf cfg.users.enable {
          neededForUsers = true;
        };
        unixRootPassword = mkIf cfg.users.enable {
          neededForUsers = true;
        };
      };
    };

    environment.sessionVariables.SOPS_AGE_KEY_FILE = cfg.sopsKeyFile;

    users = mkIf cfg.users.enable {
      mutableUsers = false;
      users = {
        root.hashedPasswordFile = config.sops.secrets.unixRootPassword.path;
        ${cfg.username} = {
          hashedPasswordFile = config.sops.secrets.unixPassword.path;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxJhslVg1p7z/RcbMefJHoyyazS0c91U1MKBgVQrtuy 2025-12-20" # managed by extract-pub-key
          ];
        };
      };
    };
  };
}
