# What is this?
This repo (which is an active work-in-progress) is my working dev setup
using nix + home-manager. There are a few things I still install via Homebrew,
but this setup gives me all of my configuration and most of the tools (including
some appliance-team-specific tools).

# Setup
1. [Install Nix](https://nixos.org/download.html#nix-install-macos)
2. Clone this repo to `~/.config/nixpkgs` and determine what you want to use from it. There's a fair
   bit of stuff that's unique to me (surprise!), and some things that you won't
   be able to use at all, because it's encrypted. `home-manager` is usually
   pretty good about not overwriting files that already exist on disk (e.g.
   `~/.bashrc`), but you should understand what's going to go where before you
   start using this.
3. Once you've decided what you want to use, [install home-manager in standalone
   form using
   flakes](https://nix-community.github.io/home-manager/index.html#ch-nix-flakes),
   using this repo as the base.
4. Read [how to use
   `home-manager`](https://nix-community.github.io/home-manager/index.html#ch-usage)
5. If you install Mac application packages via `home-manager`, then make sure
   you use something like `check-nix-apps` that's included in this repo, to make
   them available to whatever launcher you use.
6. To realize changes in your environment, rebuild and switch to the new
   generation with: `home-manager switch --flake ~/.config/nixpkgs#work` (or
   whatever you end up calling the attribute that you use).
7. To update the flake pins, invoke `nix flake update` in this directory. This
   will update to the latest version of the `inputs` in `flake.nix`.
