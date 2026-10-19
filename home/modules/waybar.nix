{ ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  xdg.configFile."waybar/config".source =
    ../../config/waybar/config-sway;

  xdg.configFile."waybar/style.css".source =
    ../../config/waybar/style.css;

  xdg.configFile."waybar/scripts/world-clock.sh" = {
    source = ../../config/waybar/scripts/world-clock.sh;
    executable = true;
  };
}
