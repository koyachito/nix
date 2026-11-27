{ pkgs, pkgs-unstable, config, ... }:
let
  # コマンド名 → Flatpak アプリID。services.flatpak.packages と
  # shell alias (コマンド名そのままで起動) の両方をここから生成する。
  flatpakApps = {
    firefox = "org.mozilla.firefox"; # chrome の代替。Surfingkeys は Firefox 版を入れる
    chromium = "org.chromium.Chromium"; # Google Meet 専用 (Firefox だと Meet の WebRTC 最適化が効きにくい)
    libreoffice = "org.libreoffice.LibreOffice";
    vlc = "org.videolan.VLC";
    signal = "org.signal.Signal";
    zathura = "org.pwmt.zathura";
  };
in
{
  home.packages = with pkgs; [
    # --- GUIアプリ (nixpkgs側はシステム一体のユーティリティと開発ツールのみ。他は下の services.flatpak) ---
    pavucontrol
    vscodium # 開発ツールは sandbox だとホストのツールチェーンが呼べないので nixpkgs (OSSビルド、拡張は Open VSX)
    remmina # SSHトンネルで ~/.ssh の鍵が必要になるため nixpkgs

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
    go

    # --- Lint・フォーマッタ ---
    shellcheck
    shfmt
    norminette

    # --- LSP等 (NixOSではMasonのバイナリが動かないためnixで入れる) ---
    clang-tools # clangd
    gopls
    gofumpt
    gotools # goimports (LazyVim go extraの保存時フォーマットで使用)
    pyright
    ruff
    lua-language-server
    nixd
    stylua
    tree-sitter # nvim-treesitter (mainブランチ) のパーサビルドに必要

    # --- CLIユーティリティ ---
    bat
    btop
    eza
    fastfetch
    fd
    fzf
    jq
    ripgrep
    trash-cli # nvim (snacks explorer) のファイル削除をゴミ箱行きにする
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

  # ルール: 「外部コンテンツを開く系」GUI は flatpak (sandbox の価値が高い)。
  # nixpkgs に残るのは技術的必然のみ
  # (kitty / codium = 開発ツールはホストのツールチェーンと一体で sandbox 化は本末転倒、
  #  remmina = SSH鍵アクセス、pavucontrol / nm-applet = システム一体のユーティリティ)。
  # slack / discord はアプリ廃止、ブラウザ版に移行済み (Signal は Web 版が存在しない)。
  services.flatpak = {
    enable = true;
    packages = builtins.attrValues flatpakApps ++ [
      # Chromium の VA-API 動画デコードに使う Intel ドライバ拡張。GPU 検出で
      # 自動導入されるはずだが、Meet のハードウェアデコード前提なので明示して確保する。
      # ブランチは Chromium のランタイム (org.freedesktop.Platform//25.08) に合わせること。
      "org.freedesktop.Platform.VAAPI.Intel//25.08"
    ];

    # ブラウザ等はセキュリティ更新が命なので自動更新を有効化
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    # Electron系は X11(xwayland) に落ちると fcitx5 (waylandFrontend) が効かない。
    # Wayland ネイティブで起動させる。
    overrides = {
      "org.signal.Signal".Environment.ELECTRON_OZONE_PLATFORM_HINT = "auto";
      # デフォルトは xdg-documents/xdg-download しか見えず、yazi から渡した
      # PDF が sandbox 内で読めずに真っ黒になる。閲覧専用なので home は ro で足りる。
      "org.pwmt.zathura".Context.filesystems = [ "home:ro" "/mnt:ro" "/run/media:ro" ];
    };
  };

  # flatpak アプリをコマンド名そのままで起動できるようにする (firefox, vlc, ...)
  programs.bash.shellAliases = builtins.mapAttrs (_: id: "flatpak run ${id}") flatpakApps;

  # Existing, tested application settings from koyachito/dotfiles.
  xdg.configFile."kitty" = { source = ../../config/kitty; recursive = true; };
  # nvim は out-of-store symlink にする。lazy.nvim が lazy-lock.json を書き換えるため
  # 読み取り専用の store symlink だと更新できない。rebuild なしで設定の試行錯誤もできる。
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/koyachito/nix/config/nvim";
  xdg.configFile."mako" = { source = ../../config/mako; recursive = true; };
  xdg.configFile."yazi" = { source = ../../config/yazi; recursive = true; };
  # zathura は flatpak なので sandbox 内の XDG_CONFIG_HOME (~/.var/app/...) に配置する
  home.file.".var/app/org.pwmt.zathura/config/zathura" = { source = ../../config/zathura; recursive = true; };
  # chromium (flatpak) の起動フラグ。zathura 同様 sandbox 内の XDG_CONFIG_HOME に置く。
  # - ozone-platform-hint=auto: Wayland ネイティブ起動 (XWayland に落とさない)
  # - enable-wayland-ime: fcitx5 (waylandFrontend / text-input-v3) を効かせる
  # - VaapiVideoDecodeLinuxGL / AcceleratedVideoDecodeLinuxGL: VA-API ハードウェアデコード。
  #   バージョンで feature 名が変わったため新旧併記 (未知の名前は無視されるだけで無害)
  home.file.".var/app/org.chromium.Chromium/config/chromium-flags.conf".text = ''
    --ozone-platform-hint=auto
    --enable-wayland-ime
    --enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder
  '';
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
