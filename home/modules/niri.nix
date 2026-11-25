{ ... }:
{
  # Niri itself is installed by programs.niri in NixOS.
  # Home Manager only places the config file (validated at build via niri validate).
  xdg.configFile."niri/config.kdl".source = ../../config/niri/config.kdl;
}
