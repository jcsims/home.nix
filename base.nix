{
  pkgs,
  lib,
  specialArgs,
  ...
}:
{
  home.username = specialArgs.username;
  home.homeDirectory = specialArgs.homedir;
  home.packages =
    (lib.attrValues specialArgs.extraPackages)
    ++ (with pkgs; [
      _1password-cli
      aspell
      aspellDicts.en
      babashka
      cachix
      specialArgs.pkgs-unstable.clojure-lsp
      clojure
      exercism
      fd
      fish
      git
      go
      htop
      jdk17
      jq
      lua-language-server
      neil
      (nerdfonts.override { fonts = [ "Hack" ]; })
      nil
      nix-diff
      nix-tree
      nixfmt-rfc-style
      nodePackages.bash-language-server
      ripgrep
      rustup
      shellcheck
      tmux
      tokei
      tree
      vulnix
      watch
      xz
    ]);

  programs.git = {
    enable = true;
    userName = "Chris Sims";
    userEmail = "chris@jcsi.ms";
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
      github.user = "jcsims";
    };
  };

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.cargo/bin"
    "$(${pkgs.go}/bin/go env GOPATH)/bin"
  ];

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

      ${pkgs.emacs}/bin/emacsclient -ne "(present-open-bookmark-frame)"
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

  # Set up fish
  programs.fish = import ./fish.nix { inherit pkgs; };

  programs.bat = {
    enable = true;
    config.theme = "Monokai Extended";
  };

  programs.nix-index = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
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
