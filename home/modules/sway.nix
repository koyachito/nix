{ ... }:
{
  # Sway itself is installed by programs.sway in NixOS.
  # Home Manager only manages the user session and Sway configuration.
  wayland.windowManager.sway = {
    enable = true;
    package = null;
    checkConfig = false;  # Validate with sway -C after installing.
    config = null;
    extraConfig = builtins.readFile ../../config/sway/config-nixos;
    systemd.enable = true;
  };
}
