{ lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
  inherit (types) submodule str;
in
{
  options.secrets = {
    enable = mkEnableOption "secrets management";

    sopsKeyFile = mkOption {
      type = str;
      default = "/var/lib/sops/age-keys.txt";
      description = "Path to the sops age key file";
    };

    username = mkOption {
      type = str;
      description = "The username for the system";
    };

    # supposedly you can set this to avoid github rate limiting.
    # secret should be a personal access token, supposedly it
    # doesn't need any extra permissions. i have no clue if it's
    # working, but i have no errors and haven't been rate limited.
    enableGithubToken = mkEnableOption "the system GitHub token";

    users = mkOption {
      description = "Set root and system user passwords.";
      default = { };
      type = submodule {
        options = {
          enable = mkEnableOption "user & root passwords";
        };
      };
    };
  };
}
