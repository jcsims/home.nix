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

  outputs = {
    nixpkgs,
    home-manager,
    hue,
    unstable,
    ...
  }: let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
    unstable_pkgs = unstable.legacyPackages.${system};
  in {
    homeConfigurations = {
      personal = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./base.nix
          ./home.nix
        ];

        extraSpecialArgs = rec {
          # Use this to pull in packages as flakes.
          extraPackages = {
            exercism = pkgs.exercism;
            # Pull in a newer babashka so I can get > 1.0.168:
            # https://github.com/babashka/process/commit/9e19562e108381be7bced275a9065dc182ec1c62
            babashka = unstable_pkgs.babashka;
          };
          unfree-packages = [];
          username = "jcsims";
          homedir =
            if pkgs.stdenv.isDarwin
            then "/Users/${username}"
            else "/home/${username}";
        };
      };
      work = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./base.nix
          ./work.nix
        ];

        extraSpecialArgs = rec {
          # TODO: Needed for pulling in the appliance repo - better way?
          inherit system;
          # Use this to pull in packages as flakes.
          extraPackages = {
            hue = hue.packages.${system}.default;
            # Pull in a newer babashka so I can get > 1.0.168:
            # https://github.com/babashka/process/commit/9e19562e108381be7bced275a9065dc182ec1c62
            babashka = unstable_pkgs.babashka;
          };
          unfree-packages = ["elasticsearch"];
          username = "chrsims";
          homedir =
            if pkgs.stdenv.isDarwin
            then "/Users/${username}"
            else "/home/${username}";
        };
      };
    };
  };
}
