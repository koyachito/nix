{ pkgs, pkgs-unstable, ... }:
{
  home.packages = with pkgs; [
    # --- GUIアプリ (nixpkgs側に残すもの。flathub組は下の services.flatpak 参照) ---
    remmina
    signal-desktop # 日本語入力(Electron + fcitx5 wayland)が壊れやすいので flatpak にしない
    zathura
    pavucontrol

    # --- デスクトップ環境 (sway / niri 共用) ---
    pkgs-unstable.kitty # 0.50.0: IME候補窓アンカー・preeditカーソル修正。26.11で stable に戻す
    fuzzel
    waybar
    mako
    swaylock
    swaylock-plugin
    swayidle
    kanshi
    awww
    mpvpaper
    wlsunset

    # --- スクリーンショット・録画・クリップボード ---
    grim
    slurp
    wf-recorder
    wl-clipboard

    # --- システム操作・常駐 ---
    brightnessctl
    playerctl
    libnotify
    networkmanagerapplet
    bluetui
    procps
    upower

    # --- エディタ・VCS・AIツール ---
    neovim
    git
    gh
    lazygit
    tmux
    claude-code
    codex

    # --- 言語・ツールチェーン ---
    clang
    gnumake
    cmake
    nodejs
    typescript
    python3
    uv
    rustc
    cargo

    # --- Lint・フォーマッタ ---
    shellcheck
    shfmt
    norminette

    # --- CLIユーティリティ ---
    bat
    btop
    eza
    fastfetch
    fd
    fzf
    jq
    ripgrep
    tree
    unzip
    yazi

    # --- メディア・文書 ---
    ffmpeg
    yt-dlp
    whisper-cpp
    pandoc
    typst

    # --- おたのしみ ---
    cmatrix
    fortune
  ];

  # GUIアプリは flathub から宣言管理 (nix-flatpak)。
  # 本家ビルド + sandbox + ディストリ更新を待たない、が狙い。
  # slack / discord はアプリ廃止、ブラウザ版に移行済み。
  # signal-desktop は日本語入力(Electron + fcitx5 wayland)が壊れやすいので nixpkgs 側に残す。
  services.flatpak = {
    enable = true;
    packages = [
      "org.mozilla.firefox"            # chrome の代替。Surfingkeys は Firefox 版を入れる
      "com.vscodium.codium"            # vscode の代替 (OSSビルド、拡張は Open VSX)
      "org.libreoffice.LibreOffice"
      "org.videolan.VLC"
    ];

    # ブラウザ等はセキュリティ更新が命なので自動更新を有効化
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    # Electron系は X11(xwayland) に落ちると fcitx5 (waylandFrontend) が効かない。
    # Wayland ネイティブで起動させる。日本語入力が効かない場合は
    # `flatpak run com.vscodium.codium --enable-wayland-ime` で要確認。
    overrides = {
      "com.vscodium.codium".Environment.ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };

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
      --command "${pkgs.mpvpaper}/bin/mpvpaper -o 'loop-file=no keep-open=yes mute=yes' '*' /home/koyachito/Videos/undertale.webm"
  '';
  };
}
