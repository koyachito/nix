# NixOS + Sway migration: first boot

This is an **overlay** for `koyachito/dotfiles`, not a standalone repo.
Copy the files from this overlay into a checked-out copy of that repository.
No existing source files have been deleted or overwritten by this overlay.

## Design decisions

- NixOS 26.05 stable, `x86_64-linux`, user `koyachito`.
- Only Sway; no Hyprland or Arch/Fedora package manager compatibility.
- NixOS owns boot/network/audio/display-manager/IME integration.
- Home Manager owns user packages and per-app configuration.
- Legacy configs for Kitty, Neovim, Mako, Yazi, Zathura, Pandoc and Waybar are reused.
- The existing Waybar clock still shows Tokyo and Mexico City.
- Keymap: Japanese physical keyboard (`xkb_layout jp`). Adjust if wrong.

## Pre-install checks

1. Back up important personal files; a NixOS install can destroy existing partitions.
2. Preserve the old configuration in Git history or a separate backup. Do not merge or delete existing files yet.
3. Verify UEFI boot mode. This initial template assumes UEFI + systemd-boot.
4. Boot the NixOS 26.05 installer and handle partitioning/mounting separately.
   **No partition commands are included here, intentionally.**

## Supply real hardware configuration (required)

After partitioning and mounting the target filesystem at `/mnt`, run the
installer's `nixos-generate-config --root /mnt`. It produces
`/mnt/etc/nixos/hardware-configuration.nix` with the actual filesystem UUIDs,
initrd modules and mount configuration.

Copy that generated file into:

`hosts/laptop/hardware-configuration.nix`

inside the repository on the installation target. **Do not copy a configuration
from a different computer or use a fake filesystem UUID.**

`flake.nix` intentionally imports the hardware file through
`hosts/laptop/default.nix`. Until the real file is present, Nix evaluation
and installation will fail. This is expected.

When using a Git checkout with flakes, `git add` the new files (including the
hardware file) before evaluating them. They need not be committed just to test.
Generate `flake.lock` with `nix flake lock` and also add it to Git.

## Build/install sequence

After the overlay, real hardware file and `flake.lock` are present, inspect the
configuration before installing:

- `nix flake show`
- `nix eval .#nixosConfigurations.koyachito-laptop.config.system.build.toplevel.drvPath`
- `nixos-rebuild build --flake .#koyachito-laptop` (on NixOS)

From the installer, after mounting `/mnt` and preparing the repository,
`nixos-install --flake /path/to/repository#koyachito-laptop` installs that
configuration. The path must exist in the installer environment.

Set the `koyachito` account password **interactively**; do not put a cleartext
password in the repository. Do not reboot before ensuring you can log in.

## First-login smoke test

1. Log in using greetd/tuigreet; the Sway session should start.
2. Verify `Super+Enter` (Kitty), `Super+D` (Fuzzel), `Super+Y` (Yazi), and `Super+X` (power menu).
3. Verify Waybar, Mako, Firefox, sound controls and screenshots.
4. Validate Sway configuration with `sway -C -c ~/.config/sway/config`.
5. Verify Japanese input manually in a GTK app; initial hotkey is not final.
6. Check `journalctl --user -b` and `journalctl -b` for errors.

## Deliberately unfinished (next stage)

- xremap: `KEY_HENKAN` to Super, including uinput/evdev permissions.
- CapsLock to toggle Japanese/English via fcitx5; old Arch mapping
  (CapsLock short press Esc / hold Ctrl) must not be copied unchanged.
- kanshi monitor profiles and hotplug behavior.
- Full user service migration (Waybar/Mako/fcitx5 currently started by Sway).
- Battery warning timers and KDE Connect permissions / firewall rules.
- Btrfs/Snapper/swap redesign and disk-specific settings.
- Version-pinned `flake.lock`; generated in a Nix-enabled environment.
- CI `nix flake check`/evaluation after actual hardware configuration is present.
- Cleanup of old Arch and Hyprland files *after* the first successful reboot.

## Validation status

This overlay was authored from the public repository's `main` branch snapshot
`84745f6637ef05da0e1b29e9cedb3c8bb9309651` and cross-checked against
NixOS 26.05 / Home Manager documentation. It was **not** evaluated by Nix or
boot-tested: no Nix executable or target hardware was available in the authoring
environment. Do not treat this as a tested, turnkey OS installer.
