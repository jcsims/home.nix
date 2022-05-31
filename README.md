# What is this?
This repo (which is an active work-in-progress) is my working dev setup
using nix + home-manager. There are a few things I still install via Homebrew,
but this setup gives me all of my configuration and most of the tools (including
some appliance-team-specific tools). 

# Setup
1. [Install Nix](https://nixos.org/download.html#nix-install-macos)
2. [Install home-manager in standalone
   form](https://nix-community.github.io/home-manager/index.html#sec-install-standalone)
3. Read [how to use
   `home-manager`](https://nix-community.github.io/home-manager/index.html#ch-usage)
4. Clone this repo and determine what you want to use from it. There's a fair
   bit of stuff that's unique to me (surprise!), and some things that you won't
   be able to use at all, because it's encrypted. `home-manager` is usually
   pretty good about not overwriting files that already exist on disk (e.g.
   `~/.bashrc`), but you should understand what's going to go where before you
   start using this.
5. Replace `~/.config/nixpkgs` with this repo, and start using it.
6. If you install Mac application packages, then make sure you have something
   like `check-nix-apps` that's included in this repo, to make them available to
   whatever launcher you use.
