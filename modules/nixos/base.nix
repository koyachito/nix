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

  # RAM 8GB でブラウザ2つ+Orca常駐だとディスクスワップ張り付きで音切れ・カクつきが出る。
  # 圧縮RAMスワップを挟んでディスクへの退避を遅らせる。zstdでおよそ3倍圧縮が見込めるので
  # RAMの50% (約4GiB) を上限にしても実質コストは1.3GiB程度。
  # priority は既定の5のままで、ディスクスワップ (-2) より高く、zramが先に使われる。
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  # zram前提のチューニング。swappiness はディスク時代の既定 (60) だと圧縮退避を
  # 渋りすぎるので引き上げる (zram単独構成の推奨は180だがディスク併用なので控えめに)。
  # page-cluster=0 はスワップ読みの先読み (既定8ページ) を止める。zramはランダム
  # アクセスが速いので先読みは無駄な伸長を招くだけ。
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.page-cluster" = 0;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
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
