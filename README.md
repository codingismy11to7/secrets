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

1. clone the repo, and

2. set up [direnv](https://direnv.net/)

OR

2. run `nix develop --command bash -c secrets-menu`

to work with secrets.

To add to your system configuration, do something like the following:

### add the input

```nix
inputs = {
  # some inputs ...

  home-manager = { ... };
  nixpkgs.url = "...";

  secrets = {
    # you'll eventually want to push, but while integrating
    # it's probably easiest to point to a local clone. But
    # when you have one pushed, change to a github: url.
    url = "path:/home/codingismy11to7/dev/secrets";
    # url = "github:codingismy11to7/secrets";

    inputs.nixpkgs.follows = "nixpkgs";

    # optional, if you have a systems input
    inputs.systems.follows = "systems";
  };
  ...
}
```

### and configure the secrets

```nix
# varies according to your flake configuration, of course, but
# probably a file where users are configured

# add the import
imports = [
  inputs.secrets.nixosModules.default
];

# and configure your secrets
secrets = {
  username = "myuser"; # or `inherit username;`, assuming you have a username variable

  # set up the system to use the system key
  enable = true;

  # to set a token in nix configuration, probably don't need
  # to enable.
  enableGithubToken = false;

  # maybe don't enable this right away until you've confirmed
  # everything is working. this runs account passwords from secrets,
  # to be used with `mutableUsers = false`
  users.enable = true;
};

# and again, varies per system, but somewhere that home manager
# is configured

home-manager = {
  ...
  users.${username} = {
    imports = [
      ...
      # add the import
      inputs.secrets.homeManagerModules.default
    ];

    # turn on user secrets, which is currently just your SSH key
    secrets.enable = true;
  };
};
```
