{
  description = "Home Manager configuration of Chris Sims";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hue = {
      url = "github:SierraSoftworks/hue?rev=4f597d972ab553208074ba19b9aaaa442fa8e43c";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:Nix-Community/emacs-overlay";
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    hue,
    emacs-overlay,
    ...
  }: let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
      overlays = [(import emacs-overlay)];
    };
    pkgs-unstable = import nixpkgs-unstable {
      system = "aarch64-darwin";
      config.allowUnfree = true;
      overlays = [(import emacs-overlay)];
    };
    x86-pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      overlays = [(import emacs-overlay)];
    };
    x86-pkgs-unstable = import nixpkgs-unstable {
      system = "x86_64-linux";
      config.allowUnfree = true;
      overlays = [(import emacs-overlay)];
    };
  in {
    homeConfigurations = {
      personal = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./base.nix
          ./home.nix
          ./emacs.nix
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
      work = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./base.nix
          ./work.nix
          ./emacs.nix
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
