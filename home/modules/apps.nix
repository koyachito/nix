{ pkgs, ... }:
{
  # A first-pass selection from install-common.sh + install-sway.sh.
  home.packages = with pkgs; [
	signal-desktop
	gh
	claude-code
	codex
	whisper-cpp
	unzip
	yt-dlp
    firefox
	google-chrome
    kitty
    fuzzel
    waybar
    mako
    swaylock
	swaylock-plugin
	mpvpaper
    swayidle
    awww
    grim
    slurp
    wf-recorder
    wl-clipboard
    wlsunset
    brightnessctl
    playerctl
    pavucontrol
    networkmanagerapplet
    libnotify
    procps
    upower
    kanshi
    neovim
	fastfetch
    git
    lazygit
    bat
    btop
    eza
    fd
    fzf
    jq
    ripgrep
    tree
    yazi
    zathura
    pandoc
    typst
    tmux
    clang
    gnumake
    cmake
    nodejs
    typescript
    rustc
    cargo
    shellcheck
    shfmt
    vscode
    norminette
	discord
	slack
	bluetui
	ffmpeg
	python3
	uv
	cmatrix
  ];

  # Existing, tested application settings from koyachito/dotfiles.
  xdg.configFile."kitty" = { source = ../../config/kitty; recursive = true; };
  xdg.configFile."nvim" = { source = ../../config/nvim; recursive = true; };
  xdg.configFile."mako" = { source = ../../config/mako; recursive = true; };
  xdg.configFile."yazi" = { source = ../../config/yazi; recursive = true; };
  xdg.configFile."zathura" = { source = ../../config/zathura; recursive = true; };
  xdg.configFile."pandoc" = { source = ../../config/pandoc; recursive = true; };

  # Correct the existing typo: 'atch-counter' -> 'match-counter'.
  xdg.configFile."fuzzel/fuzzel.ini".text = builtins.replaceStrings
    [ "atch-counter=yes" ]
    [ "match-counter=yes" ]
    (builtins.readFile ../../config/fuzzel/fuzzel.ini);

  home.file.".local/bin/powermenu" = {
    source = ../../scripts/powermenu-nixos;
    executable = true;
  };

  home.file.".local/bin/rec" = {
    source = ../../scripts/rec;
    executable = true;
  };

  home.file.".local/bin/undertale-lock" = {
  executable = true;
  text = ''
    #!/bin/sh
    exec ${pkgs.swaylock-plugin}/bin/swaylock-plugin -f \
      --command "${pkgs.mpvpaper}/bin/mpvpaper -o 'loop-file=no keep-open=yes' '*' /home/koyachito/Videos/undertale.webm"
  '';
  };
}
