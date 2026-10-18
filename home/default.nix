{ ... }:
{
  imports = [
    ./modules/sway.nix
    ./modules/waybar.nix
    ./modules/apps.nix
    ./modules/shell.nix
  ];

  home.username = "koyachito";
  home.homeDirectory = "/home/koyachito";
  home.stateVersion = "26.05";

  xdg.enable = true;
  programs.home-manager.enable = true;
}
