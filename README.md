# secrets

A Nix flake for managing personal secrets (SSH keys, system
passwords, API tokens) using
[sops](https://github.com/getsops/sops) and
[age](https://github.com/FiloSottile/age) encryption.
It provides:

- An interactive CLI (`secrets-menu`) for creating, viewing,
  and modifying secrets
- A passphrase-protected master key (`keys.txt.age`) that
  encrypts everything
- NixOS and Home Manager modules that deploy your secrets to
  the system at build time

The idea is you clone this repo, run the menu to set up your
keys and secrets, then import the flake into your NixOS
configuration. Your secrets stay encrypted in git, and get
decrypted on the target system by sops using the age key you
deploy.

This is my personal secrets repo, but it's structured to be
forked and used as a starting point for your own.

## Quick start

1. Fork/clone the repo
2. Enter the dev shell:
   - set up [direnv](https://direnv.net/), or
   - run `nix develop`
3. Run `secrets-menu`
4. Select **Manage System Key** > **Create New System Key**
   - This generates an age keypair, encrypts it with a
     passphrase you choose, and installs it to the system
5. From here you can manage passwords, SSH keys, and other
   secrets through the menu

## NixOS integration

Once your secrets are set up, add the flake to your system
configuration.

### Add the input

```nix
inputs = {
  nixpkgs.url = "...";
  home-manager = { ... };

  secrets = {
    # point to a local clone while integrating,
    # switch to github: url when ready
    url = "path:/path/to/secrets";
    # url = "github:youruser/secrets";

    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### Configure NixOS secrets

```nix
imports = [
  inputs.secrets.nixosModules.default
];

secrets = {
  enable = true;
  username = "myuser";

  # manage user/root passwords via secrets
  # (use with mutableUsers = false)
  users.enable = true;

  # optional: github token for nix to avoid rate limits
  enableGithubToken = false;
};
```

### Configure Home Manager secrets

```nix
home-manager.users.${username} = {
  imports = [
    inputs.secrets.homeManagerModules.default
  ];

  # deploys your SSH key to ~/.ssh/id_ed25519
  secrets.enable = true;
};
```
