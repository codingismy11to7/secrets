{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.secrets;
in
{
  imports = [ ./options.nix ];

  config = mkIf cfg.enable {
    sops = {
      age.keyFile = cfg.sopsKeyFile;
      defaultSopsFile = ../secrets.yaml;
      secrets.guzzlerOauthClientSecret = { };
      secrets.nextcloudPassword = { };
      secrets.sshPrivKey = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
    };

    home.sessionVariables.SOPS_AGE_KEY_FILE = cfg.sopsKeyFile;
  };
}
