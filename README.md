# Setup
1. [Install Nix](https://nixos.org/download.html#nix-install-macos)
2. Clone this repo to `~/.config/home-manager`
3. Once you've decided what you want to use, [install home-manager in standalone
   form using
   flakes](https://nix-community.github.io/home-manager/index.html#ch-nix-flakes),
   e.g. `nix run home-manager/master -- switch`
4. After it's installed, update using `home-manager switch`
5. To update the flake pins, invoke `nix flake update` in this directory. This
   will update to the latest version of the `inputs` in `flake.nix`.
