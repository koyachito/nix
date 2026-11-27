{ ... }:
{
  imports = [
    ./modules/sway.nix
    ./modules/niri.nix
    ./modules/waybar.nix
    ./modules/apps.nix
    ./modules/orca.nix
    ./modules/battery-warning.nix
    ./modules/shell.nix
  ];

  home.username = "koyachito";
  home.homeDirectory = "/home/koyachito";
  home.stateVersion = "26.05";

  xdg.enable = true;
  # user-dirs.dirs が無いと flatpak が xdg-download 等を解決できず、
  # Firefox のダウンロードがサンドボックス内 tmpfs に落ちて終了時に消える。
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  programs.home-manager.enable = true;
}
