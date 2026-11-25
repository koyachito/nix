
{ config, lib, pkgs, pkgs-unstable, ... }:
{
  security.pam.services.swaylock-plugin = {};

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = [ ];
  };

  # niri お試し中。Swayと並行インストールし、tuigreetで選択する。
  # programs.niri がセッション登録・portal(gnome/gtk)・keyring を面倒見てくれる。
  programs.niri.enable = true;

  # niri は XWayland 非内蔵。xwayland-satellite が PATH にあれば
  # niri がオンデマンドで起動して DISPLAY を通してくれる。
  environment.systemPackages = [ pkgs.xwayland-satellite ];

  services.greetd = {
    enable = true;
    settings.default_session = {
      # --sessions: sway / niri をログイン時に選択。--remember-session で前回を記憶。
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
      user = "greeter";
    };
  };

  # クラムシェル運用: 外部モニタ接続中(=docked判定)は蓋を閉じてもサスペンドしない。
  # モニタなしで蓋を閉じたときは従来どおりサスペンド (HandleLidSwitch デフォルト)。
  # 蓋閉じ時の内蔵画面オフは niri が自動でやる。
  services.logind.settings.Login = {
    HandleLidSwitchDocked = "ignore";
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # GUIアプリの一部は flathub から導入する (home/modules/apps.nix の services.flatpak 参照)。
  # ユーザー単位の宣言管理は nix-flatpak (home-manager module) が担うが、
  # flatpak 本体と dbus/portal 連携はシステム側での有効化が必要。
  services.flatpak.enable = true;

  # home-manager activation は flatpak-managed-install の完了を待つ。
  # 初回導入や大型更新はGB級のダウンロードになり、デフォルト5分の
  # 起動タイムアウトだと 殺される→再起動→途中再開 のループになるため延長。
  # home-manager 本体も "5m" を定義するようになったため mkForce で上書きする。
  systemd.services."home-manager-koyachito".serviceConfig.TimeoutStartSec = lib.mkForce "60min";

  # kitty上で変換候補・未確定文字が画面に残るバグ対策。
  # fcitx5 5.1.23 の stale preedit 修正 (fcitx/fcitx5#1690) を unstable から先行取得。
  # i18n.inputMethod.package の上書きでは QT_PLUGIN_PATH 等に旧版が残るため、
  # モジュールが参照する qt6Packages.fcitx5-with-addons ごと差し替える。
  # 26.05 は 5.1.19 のまま。26.11 で追いついたらこの overlay を外す。
  nixpkgs.overlays = [
    (final: prev: {
      qt6Packages = prev.qt6Packages // {
        fcitx5-with-addons = pkgs-unstable.qt6Packages.fcitx5-with-addons;
      };
    })
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    # unstable製 im-fcitx5.so は stable の GTK3/glib から読み込めない
    # (glib micro mismatch) ため、IMモジュール方式をやめて Wayland
    # text-input-v3 方式に切り替える。Sway / niri どちらも対応。
    # gtk3-immodule.cache の生成もスキップ(読めないモジュールなので)。
    enableGtk3 = false;

    fcitx5 = {
      # GTK_IM_MODULE / QT_IM_MODULE を設定せず、compositor経由でIMEを使う。
      # Electron系 (flatpak) は Wayland 起動が前提 → apps.nix の overrides 参照。
      waylandFrontend = true;

      # 本体を unstable にするためアドオンも unstable で揃える(ABI不一致回避)
      addons = with pkgs-unstable; [
        fcitx5-mozc
        fcitx5-gtk
      ];

      settings = {
        globalOptions."Hotkey/TriggerKeys"."0" = "Control+space";

        inputMethod = {
          GroupOrder."0" = "Default";

          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };

          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "mozc";
        };
      };
    };
  };

  services.xremap = {
    enable = true;
    package = pkgs.xremap;
    serviceMode = "user";
    userName = "koyachito";
    watch = true;

    config = {
      modmap = [
        {
          name = "Henkan to Super";
          remap = {
            KEY_HENKAN = "KEY_LEFTMETA";
          };
        }
        {
          name = "Right Alt to Super";
          remap = {
            KEY_RIGHTALT = "KEY_LEFTMETA";
          };
        }
      ];

      keymap = [
        {
          name = "CapsLock IME toggle";
          exact_match = true;
          remap = {
            CapsLock = "C-space";
          };
        }
      ];
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}

