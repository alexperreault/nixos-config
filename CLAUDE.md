# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal NixOS + Home Manager configuration for a single machine: host `north`, user `alexp`, x86_64-linux, nixpkgs `nixos-unstable`. Wayland/Hyprland desktop, fish shell, foot terminal.

## Commands

All routine work goes through the `justfile`:

```
just nix-rebuild        # sudo nixos-rebuild switch --flake .   (system)
just nix-rebuild-test   # sudo nixos-rebuild test --flake .     (system, no bootloader entry)
just home-switch        # home-manager switch --flake .  + fsel --refresh-cache  (user)
just update-flake       # nix flake update
just commit             # git add . + commit with generation numbers + push
just update             # update-flake → nix-rebuild → wait-net → home-switch → commit
```

There are no tests, linters, or a build step. Validation is "does it rebuild".

`just wait-net` exists because `nixos-rebuild switch` restarts NetworkManager; the following `home-switch` needs `cache.nixos.org` reachable. Keep it between system and home rebuilds in any chained recipe.

## Architecture

**Two independent configurations, not one.** `flake.nix` exposes:

- `nixosConfigurations.north` — `configuration.nix` + `hardware-configuration.nix`
- `homeConfigurations.alexp` — `home.nix`, **standalone** Home Manager (not imported as a NixOS module)

Consequence: system-level and user-level changes are applied by separate commands and produce separate generation numbers. Changing `home.nix` never requires a `nixos-rebuild`, and vice versa. When adding a package, decide which layer: system-wide/needed at boot or for a service → `configuration.nix` `environment.systemPackages`; anything user-facing → `home.nix` `home.packages`.

**Flake inputs as package sources.** `naviterm`, `zen-browser`, `fsel`, `claude-code` are consumed in `home.nix` as `inputs.<name>.packages.${pkgs.stdenv.hostPlatform.system}.default`. Note that `naviterm` and `fsel` deliberately do *not* set `inputs.nixpkgs.follows = "nixpkgs"` — they broke when forced onto this flake's nixpkgs. Don't "fix" that by re-adding the follows line.

`inputs` is threaded to both configurations via `specialArgs` / `extraSpecialArgs`, so any module can take `{ inputs, ... }`.

## Dotfiles: two delivery mechanisms

`dotfiles/` holds non-Nix config, wired up in `home.nix` in two different ways:

- **`home.file."...".source`** (foot, naviterm, fsel) — copied into the Nix store. Editing the file does nothing until `just home-switch`.
- **`xdg.configFile."hypr".source = mkOutOfStoreSymlink`** — `~/.config/hypr` symlinks straight into this repo. Hyprland edits take effect without any rebuild.

Because the Hyprland config is a symlink, Hyprland's automatic hot reload does **not** fire; run `hyprctl reload` manually after editing (see `docs/cursed_knowledge.md`).

`dotfiles/hypr/hyprland.lua` uses Hyprland's Lua config API (the `hl` global: `hl.monitor`, `hl.bind`, `hl.env`, `hl.on`, `hl.config`, …), not the classic `hyprland.conf` syntax. It is organized into commented sections (MONITORS, AUTOSTART, LOOK AND FEEL, KEYBINDINGS, WINDOWS AND WORKSPACES, …); keep new settings in the matching section. `.luarc.json` points at `/usr/share/hypr/stubs`, which does not exist on NixOS — LSP completion for `hl` will be unavailable.

A local clone of the Hyprland wiki lives at `~/hyprland-wiki` (outside this repo). Grep `~/hyprland-wiki/content/` — notably `Configuring/` — instead of fetching wiki.hypr.land when looking up options or dispatchers. It is a plain clone with no auto-update, so it goes stale: run `git -C ~/hyprland-wiki pull` from time to time, and especially if a documented option doesn't work or an option you expect to find is missing.

Apps are launched through `uwsm app --` (the session is started by uwsm from fish's `loginShellInit`), so autostart/keybind commands should keep that prefix.

## Conventions

- Commit messages are generated, not written: `n<nixos-generation> : h<home-generation>` (e.g. `n58 : h32`). Use `just commit` rather than hand-writing a message, so the numbers match the generations actually installed.
- `system.stateVersion` / `home.stateVersion` (`26.05`) must not be changed.
- Don't touch cursed_knowledge.md
