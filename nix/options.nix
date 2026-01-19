{ lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
  inherit (types) submodule str absolutepath;
in
{
  options.secrets = {
    enable = mkEnableOption "secrets management";

    sopsKeyFile = mkOption {
      type = absolutepath;
      default = /var/lib/sops/age-keys.txt;
      description = "Path to the sops age key file";
    };

    username = mkOption { };

    user = mkOption {
      description = "User secrets configuration";
      default = { };
      type = submodule {
        options = {
          enable = mkEnableOption "user & root passwords";
          username = mkOption {
            type = str;
            description = "The primary username";
          };
        };
      };
    };
  };
}
