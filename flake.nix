
{
  description = "koyachito's NixOS + Sway desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # IME修正の先行取得用 (fcitx5 5.1.23 / kitty 0.50.0)。26.11で不要になったら外す。
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flatpakの宣言的管理 (firefox / vscodium は flathub から入れる)
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, xremap-flake, nix-flatpak, ... }:
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable { inherit system; };
  in {
    nixosConfigurations.koyachito-laptop = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = { inherit pkgs-unstable; };

      modules = [
        ./hosts/laptop
        xremap-flake.nixosModules.default
        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.koyachito = import ./home;
          home-manager.sharedModules = [ nix-flatpak.homeManagerModules.nix-flatpak ];
          home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
        }
      ];
    };
  };
}

