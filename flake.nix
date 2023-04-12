{
  description = "Home Manager configuration of Chris Sims";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    unstable.url = "github:NixOS/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hue = {
      url = "github:SierraSoftworks/hue?rev=4f597d972ab553208074ba19b9aaaa442fa8e43c";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs
    , home-manager
    , hue
    , unstable
    , ...
    }:
    let
      system = "aarch64-darwin";
      unfree-pkgs = pkg:
        builtins.elem (nixpkgs.lib.getName pkg) [ "elasticsearch" "vscode" ];
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = unfree-pkgs;
      };
      unstable_pkgs = import unstable {
        inherit system;
        config.allowUnfreePredicate = unfree-pkgs;
      };
    in
    {
      homeConfigurations = {
        personal = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            ./base.nix
            ./home.nix
            ./mac-gui.nix
          ];

          extraSpecialArgs = rec {
            inherit unstable_pkgs;
            # Use this to pull in packages as flakes.
            extraPackages = {
              exercism = pkgs.exercism;
              # Pull in a newer babashka so I can get > 1.0.168:
              # https://github.com/babashka/process/commit/9e19562e108381be7bced275a9065dc182ec1c62
              babashka = unstable_pkgs.babashka;
              neovim = unstable_pkgs.neovim;
            };
            username = "jcsims";
            homedir = "/Users/${username}";
          };
        };
        work-laptop = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            ./base.nix
            ./work.nix
            ./mac-gui.nix
          ];

          extraSpecialArgs = rec {
            inherit unstable_pkgs;
            # TODO: Needed for pulling in the appliance repo - better way?
            inherit system;
            # Use this to pull in packages as flakes.
            extraPackages = {
              hue = hue.packages.${system}.default;
              # Pull in a newer babashka so I can get > 1.0.168:
              # https://github.com/babashka/process/commit/9e19562e108381be7bced275a9065dc182ec1c62
              babashka = unstable_pkgs.babashka;
              emacs = unstable_pkgs.emacs;
            };
            username = "chrsims";
            homedir = "/Users/${username}";
          };
        };
        nix-dev = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs;

          modules = [
            ./base.nix
            ./work.nix
          ];

          extraSpecialArgs = rec {
            system = "x86_64-linux";
            # Use this to pull in packages as flakes.
            extraPackages = {
              emacs-nox = nixpkgs.emacs-nox;
            };
            username = "jcsims";
            homedir = "/home/${username}";
          };
        };
      };
    };
}
