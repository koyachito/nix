
{ pkgs, ... }:
{
  security.pam.services.swaylock-plugin = {};

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = [ ];
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
      user = "greeter";
    };
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      addons = with pkgs; [
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

