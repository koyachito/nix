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
