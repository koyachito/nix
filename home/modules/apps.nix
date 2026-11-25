{ pkgs, pkgs-unstable, ... }:
{
  home.packages = with pkgs; [
    # --- GUIアプリ (nixpkgs側はシステム一体のユーティリティのみ。他は下の services.flatpak) ---
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

  # ルール: flathub にある独立GUIは全部 flatpak。nixpkgs に残るのは技術的必然のみ
  # (kitty = ターミナルの sandbox 化は本末転倒 + unstable ピン留め、
  #  pavucontrol / nm-applet = システム一体のユーティリティ)。
  # slack / discord はアプリ廃止、ブラウザ版に移行済み (Signal は Web 版が存在しない)。
  services.flatpak = {
    enable = true;
    packages = [
      "org.mozilla.firefox"            # chrome の代替。Surfingkeys は Firefox 版を入れる
      "com.vscodium.codium"            # vscode の代替 (OSSビルド、拡張は Open VSX)
      "org.libreoffice.LibreOffice"
      "org.videolan.VLC"
      "org.signal.Signal"
      "org.remmina.Remmina"
      "org.pwmt.zathura"
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
      "org.signal.Signal".Environment.ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };

  # Existing, tested application settings from koyachito/dotfiles.
  xdg.configFile."kitty" = { source = ../../config/kitty; recursive = true; };
  xdg.configFile."nvim" = { source = ../../config/nvim; recursive = true; };
  xdg.configFile."mako" = { source = ../../config/mako; recursive = true; };
  xdg.configFile."yazi" = { source = ../../config/yazi; recursive = true; };
  # zathura は flatpak なので sandbox 内の XDG_CONFIG_HOME (~/.var/app/...) に配置する
  home.file.".var/app/org.pwmt.zathura/config/zathura" = { source = ../../config/zathura; recursive = true; };
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
