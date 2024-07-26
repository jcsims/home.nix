{
  description = "Home Manager configuration of jcsims";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    hue = {
      url = "github:SierraSoftworks/hue?rev=4f597d972ab553208074ba19b9aaaa442fa8e43c";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:Nix-Community/emacs-overlay";
    mkalias.url = "github:reckenrode/mkalias";
    mkalias.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    plasma-manager,
    hue,
    emacs-overlay,
    ...
  } @ inputs: let
    overlays = [(import emacs-overlay)];

    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      overlays =
        overlays
        ++ [
          (_: _: {
            mkalias = inputs.mkalias.packages.${system}.mkalias;
          })
        ];
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };
    pkgs-unstable = import nixpkgs-unstable {
      overlays =
        overlays
        ++ [
          (_: _: {
            mkalias = inputs.mkalias.packages.${system}.mkalias;
          })
        ];
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };
    x86-pkgs = import nixpkgs {
      inherit overlays;
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    x86-pkgs-unstable = import nixpkgs-unstable {
      inherit overlays;
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  in {
    homeConfigurations = {
      "jcsims@groot" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./base.nix
          ./home.nix
          ./emacs.nix
          ./mac.nix
          ./alacritty.nix
        ];

        extraSpecialArgs = rec {
          inherit pkgs-unstable;
          # Use this to pull in packages as flakes.
          extraPackages = {
            hue = hue.packages.${system}.default;
          };
          work = false;
          username = "jcsims";
          homedir = "/Users/${username}";
        };
      };
      "csims" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./base.nix
          ./work.nix
          ./emacs.nix
          ./mac.nix
          ./alacritty.nix
        ];

        extraSpecialArgs = rec {
          inherit pkgs-unstable;
          # Use this to pull in packages as flakes.
          extraPackages = {
            hue = hue.packages.${system}.default;
          };
          work = true;
          username = "csims";
          homedir = "/Users/${username}";
        };
      };
      "jcsims@graphene" = home-manager.lib.homeManagerConfiguration {
        pkgs = x86-pkgs;
        modules = [
          ./base.nix
          ./emacs.nix
        ];

        extraSpecialArgs = rec {
          pkgs-unstable = x86-pkgs-unstable;
          extraPackages = {};
          work = false;
          username = "jcsims";
          homedir = "/home/${username}";
        };
      };
      "jcsims@taichi" = home-manager.lib.homeManagerConfiguration {
        pkgs = x86-pkgs;
        modules = [
          ./base.nix
          ./home.nix
          ./emacs.nix
          ./linux-gui.nix
          plasma-manager.homeManagerModules.plasma-manager
        ];

        extraSpecialArgs = rec {
          pkgs-unstable = x86-pkgs-unstable;
          extraPackages = {};
          work = false;
          username = "jcsims";
          homedir = "/home/${username}";
        };
      };
    };
  };
}
