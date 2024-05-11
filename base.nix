{ pkgs
, lib
, specialArgs
, ...
}:
{
  home.username = specialArgs.username;
  home.homeDirectory = specialArgs.homedir;
  home.packages =
    (lib.attrValues specialArgs.extraPackages)
    ++ (with pkgs; [
      age
      alejandra
      aspell
      aspellDicts.en
      babashka
      cachix
      specialArgs.pkgs-unstable.clojure-lsp
      clojure
      complete-alias # Aliases want completion, too!
      exercism
      fd
      fish
      gh # GitHub CLI tool
      git
      gnuplot # Used by maelstrom
      go
      godef
      golangci-lint
      specialArgs.pkgs-unstable.gopls
      gotools # godoc, for example
      htop
      jdk
      jq
      languagetool
      leiningen
      lua-language-server
      neil
      (nerdfonts.override { fonts = [ "Hack" ]; })
      nil
      nixpkgs-fmt
      nix-diff
      nix-tree
      nodePackages.bash-language-server
      pass
      pkg-config # jinx module build
      ripgrep
      rustup
      shellcheck
      texinfo # Used by borg to build docs
      tmux
      tokei
      tree
      vulnix
      watch
      xz
    ]);

  # programs.gpg.package = pkgs.gnupg.overrideAttrs (orig: {
  #   version = "2.4.0";
  #   src = pkgs.fetchurl {
  #     url = "mirror://gnupg/gnupg/gnupg-2.4.0.tar.bz2";
  #     hash = "sha256-HXkVjdAdmSQx3S4/rLif2slxJ/iXhOosthDGAPsMFIM=";
  #   };
  # });


  programs.git = {
    enable = true;
    userName = "Chris Sims";
    userEmail = "chris@jcsi.ms";
    #attributes = ["*.gpg filter=gpg diff=gpg"];
    aliases = {
      recent = "branch --sort=-committerdate --format=\"%(committerdate:relative)%09%(refname:short)\"";
    };
    includes = [
      {
        path = "~/code/work/.gitconfig";
        condition = "gitdir:~/code/work/";
      }
      {
        path = "~/code/.gitconfig";
        condition = "gitdir:~/code";
      }
    ];
    ignores = [
      ".DS_Store"

      # Emacs
      "*-autoloads.el"
      "*-pkg.el"
      "*.elc"
      "*.info"
      ".\#*"
      "auto-save-list"
      "flycheck_*.el"
      "tramp"

      # Clojure/Emacs
      ".clj-kondo"

      # LSP
      ".lsp"
    ];
    extraConfig = {
      credential.helper = "osxkeychain";
      fetch.prune = true;
      init.defaultBranch = "main";
      magit.hideCampaign = true;
      pull.rebase = true;
      rebase.autostash = true;
      status.submoduleSummary = true;
      diff.gpg.textconv = "gpg --no-tty --decrypt";
      github.user = "jcsims";
    };
  };

  # These settings are pulled from https://github.com/drduh/YubiKey-Guide
  programs.gpg = {
    enable = true;
    settings = {
      default-key = "0x32D20D5D6DB01A6B";
      charset = "utf-8";
      keyid-format = "0xlong";
      use-agent = true;
    };
  };

  home.file.".gnupg/gpg-agent.conf".text =
    ''
      default-cache-ttl 600
      max-cache-ttl 7200
    ''
    + (
      if pkgs.stdenv.isDarwin
      then ''
        pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
      ''
      else ''
      ''
    );

  programs.gpg.scdaemonSettings = {
    disable-ccid = true;
  };

  home.sessionPath =
    [
      "$HOME/bin"
      "$HOME/.cargo/bin"
      "$(${pkgs.go}/bin/go env GOPATH)/bin"
    ] ;

  home.sessionVariables = {
    CLICOLOR = 1;
    EDITOR = "$HOME/bin/e";
    VISUAL = "$HOME/bin/ec";
  };

  # Manage a bunch of files
  home.file."bin/e" = {
    text = ''
      #!/usr/bin/env bash

      emacsclient -t -a "" $@
    '';
    executable = true;
  };

  home.file."bin/ec" = {
    text = ''
      #!/usr/bin/env bash

      emacsclient -c -a "" $@
    '';
    executable = true;
  };

  home.file."bin/bookmarks" = {
    text = ''
      #!/usr/bin/env bash

      ${pkgs.emacs29}/bin/emacsclient -ne "(present-open-bookmark-frame)"
'';
    executable = true;
  };

  home.file.".aspell.conf".text = ''
    data-dir ${specialArgs.homedir}/.nix-profile/lib/aspell
  '';

  home.file.".psqlrc".text = ''
    \set COMP_KEYWORD_CASE upper
    \x auto
    \pset null ¤
  '';

  home.file.".config/clojure-lsp/config.edn".text = ''
    {:dependency-scheme  "jar"
     :java {:jdk-source-uri "file://${specialArgs.homedir}/.nix-profile/lib/src.zip"}}

  '';

  home.file.".tmux.conf".source = ./files/tmux.conf;

  home.file.".hammerspoon" = {
    source = ./files/hammerspoon;
    recursive = true;
  };

  # Set up fish
  programs.fish = import ./fish.nix { inherit pkgs; };

  programs.bat = {
    enable = true;
    config.theme = "Monokai Extended";
  };

  programs.nix-index = {
    enable = true;
  };

  home.file.".config/alacritty/alacritty.toml".source = ./files/alacritty.toml;
  programs.alacritty = {
    enable = pkgs.stdenv.isDarwin;
    # TODO: Move this back to stable after nixpkgs 24.05 is released
    package = specialArgs.pkgs-unstable.alacritty;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    # Enabled by default in home-manager 24.05
    #enableAliases = true;
    git = true;
    icons = true;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
