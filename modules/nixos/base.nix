{ pkgs, ... }:
{
  # UEFI systemd-boot assumption. Verify firmware boot mode before install.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # Orca Cloud を DNS レベルで遮断 (home/modules/orca.nix 参照、監査: ~/orca-audit-2026-11-27.md)。
  # クラウド機能は全てオプトインだが、サインイン自体を不可能にする保証として塞ぐ。
  # login.onorca.dev が全トークンの払い出し元なので、ここを塞げばリレーのセル群
  # (relay-c*.onorca.dev) にも到達不能。orca.dev 本体は更新チェック用に生かす。
  networking.hosts."0.0.0.0" = [
    "login.onorca.dev"
    "relay.onorca.dev"
    "push.onorca.dev"
    "connector.orca.dev"
    "share.onorca.dev"
    "app.orca.dev"
  ];

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # man 2/3 (syscalls, libc) — man-pages + .dev出力のmanも検索対象にする
  documentation.dev.enable = true;
  documentation.man.cache.enable = true;

  services.fstrim.enable = true;
  services.upower.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;

    # Google Meet 等の通話で音が途切れる (xrun) 対策。quantum = 1回に処理する
    # サンプル数で、既定の最小値 (32) まで下がると負荷スパイクで破綻しやすい。
    # 1024/48kHz ≈ 21ms に引き上げてバッファ耐性を優先する (通話用途なら遅延は許容範囲)。
    extraConfig.pipewire."10-clock-quantum" = {
      "context.properties" = {
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 512;
      };
    };
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    man-pages
    man-pages-posix
  ];
}
