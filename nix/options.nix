{ lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
  inherit (types) submodule str path;
in
{
  options.secrets = {
    enable = mkEnableOption "secrets management";

    sopsKeyFile = mkOption {
      type = path;
      default = /var/lib/sops/age-keys.txt;
      description = "Path to the sops age key file";
    };

    username = mkOption {
      type = str;
      description = "The username for the system";
    };

    users = mkOption {
      description = "Create root and system user and set passwords.";
      default = { };
      type = submodule {
        options = {
          enable = mkEnableOption "user & root passwords";
        };
      };
    };
  };
}
