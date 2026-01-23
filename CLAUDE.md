# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code)
when working with code in this repository.

## Project Overview

Personal secrets management system for NixOS/Home Manager.
Uses `sops` (Secrets OPerationS) with Age encryption to
manage SSH keys, system passwords, and API tokens. Designed
as a reusable Nix flake that exports NixOS and Home Manager
modules.

## Development Environment

```bash
# Enter dev shell (provides all tools + scripts as commands)
direnv allow
# OR
nix develop --command bash -c secrets-menu
```

The dev shell (defined in `nix/devshell.nix`) wraps all
`.scripts/*` as Nix binaries using `writeShellScriptBin` +
`replaceVars` for dependency injection. Tool paths are
substituted at build time via `@placeholder@` syntax.

## Architecture

**Encryption layer:** `keys.txt.age` is the passphrase-
protected master Age key. `secrets.yaml` is the sops-encrypted
secret store using that key's public recipient.

**Script system:** Scripts in `.scripts/` use `@var@`
placeholders that `pkgs.replaceVars` substitutes with Nix
store paths in `nix/devshell.nix`. When adding a new script:

1. Create the script in `.scripts/` with `@tool@` placeholders
   for dependencies
2. Add a `writeShellScriptBin` entry in `nix/devshell.nix`
   with the appropriate `replaceVars` mappings

File references (e.g. `keys.txt.age`, `secrets.yaml`) should
use `builtins.path { path = ../file; }` in `replaceVars` to
ensure they're added to the Nix store properly. This applies
to read-only usages; scripts that write to files still
reference the working directory.

**Nix modules:**

- `nix/options.nix` - Shared option declarations
- `nix/nixos.nix` - System-level: sops config, user
  passwords, SSH authorized keys, optional GitHub token
- `nix/home-manager.nix` - User-level: SSH private key
  deployment
- `nix/github-token.nix` - Optional nix access token
  configuration
- `nix/devshell.nix` - Dev environment with all scripts
  and tools

**Entry point:** `secrets-menu` is the main interactive CLI
(uses `gum` for prompts). It calls other scripts as
subcommands.

## Key Details

- Default system key location:
  `/var/lib/sops/age-keys.txt` (from `options.nix`)
- `ensure-system-key-exists` decrypts `keys.txt.age` and
  installs to the system key path with sudo
- Formatter: `nixfmt` (run via `nix fmt`)
- No test suite exists
