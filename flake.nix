{
  description = "Home Manager configuration of Chris Sims";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hue = {
      url = "github:SierraSoftworks/hue";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    hue,
    ...
  }: let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations.jcsims = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [
        ./home.nix
      ];

      extraSpecialArgs = {
        # TODO: Needed for pulling in the appliance repo - better way?
        inherit system;
        # Use this to pull in packages as flakes.
        extraPackages = {
          hue = hue.packages.${system}.default;
        };
      };
    };
  };
}
