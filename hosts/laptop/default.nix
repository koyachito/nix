{ ... }:
{
  # Generate this file ON THE TARGET COMPUTER with nixos-generate-config.
  # Do not use a copied UUID or an invented hardware configuration.
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
  ];

  networking.hostName = "koyachito-laptop";

  users.users.koyachito = {
    isNormalUser = true;
    description = "koyachito";
    extraGroups = [ "wheel" "networkmanager" "video" ];
    # Set the login password interactively, not in a public Git repository.
  };

  # Correct for a *new* installation of NixOS 26.05. Do not bump casually.
  system.stateVersion = "26.05";
}
