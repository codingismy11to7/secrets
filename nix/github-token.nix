{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.secrets;
in
mkIf cfg.enableGithubToken {
  sops = {
    templates."nix-access-tokens.conf".content = ''
      access-tokens = github.com=${config.sops.placeholder.githubNixToken}
    '';
  };

  nix.extraOptions = ''
    !include ${config.sops.templates."nix-access-tokens.conf".path}
  '';
}
