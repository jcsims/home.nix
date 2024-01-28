{
  description = "Home Manager configuration of Chris Sims";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Homebrew casks, nixified
    # documentation: https://github.com/jacekszymanski/nixcasks/
    nixcasks.url = "github:jacekszymanski/nixcasks";
    nixcasks.inputs.nixpkgs.follows = "nixpkgs";
    hue = {
      url = "github:SierraSoftworks/hue?rev=4f597d972ab553208074ba19b9aaaa442fa8e43c";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:Nix-Community/emacs-overlay";
  };

  outputs =
    { nixpkgs
    , nixpkgs-unstable
    , home-manager
    , nixcasks
    , hue
    , emacs-overlay
    , ...
    }:
    let

      overlays = [ (import emacs-overlay) ];

      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit overlays;
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit overlays;
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
    in
    {
      homeConfigurations = {
        "jcsims@groot" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            ./base.nix
            ./home.nix
            ./emacs.nix
            ./mac.nix
          ];

          extraSpecialArgs = rec {
            inherit pkgs-unstable;
            # Use this to pull in packages as flakes.
            extraPackages = {
              hue = hue.packages.${system}.default;
            };
            username = "jcsims";
            homedir = "/Users/${username}";
          };
        };
        "jcsims@patch" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            ./base.nix
            ./work.nix
            ./emacs.nix
            ./mac.nix
          ];

          extraSpecialArgs = rec {
            inherit pkgs-unstable;
            # Use this to pull in packages as flakes.
            extraPackages = {
              hue = hue.packages.${system}.default;
            };
            username = "jcsims";
            homedir = "/Users/${username}";
          };
        };
        thanos = home-manager.lib.homeManagerConfiguration rec {
          pkgs = x86-pkgs;
          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            ./base.nix
            ./work.nix
            ./emacs.nix
            ./linux-gui.nix
          ];

          extraSpecialArgs = rec {
            pkgs-unstable = x86-pkgs-unstable;
            # Use this to pull in packages as flakes.
            extraPackages = {
              hue = hue.packages."x86_64-linux".default;
            };
            username = "jcsims";
            homedir = "/home/${username}";
          };
        };
      };
    };
}
