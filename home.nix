# This repo is cloned at $HOME/.config/nixpkgs to work with home-manager.
{ config, pkgs, ... }:

let
  work-config = if builtins.pathExists ./work.nix
                then (import ./work.nix {pkgs = pkgs;})
                else {packages = [];};
in
rec {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jcsims";
  home.homeDirectory = "/Users/jcsims";

  home.packages = with pkgs; [
    act
    aspell
    aspellDicts.en
    babashka
    bashInteractive
    bash-completion
    clojure-lsp
    clojure
    emacs
    fd
    git
    gnupg
    htop
    jq
    (nerdfonts.override { fonts = [ "Hack" "RobotoMono" ]; })
    nixpkgs-fmt
    nix-tree
    nodePackages.bash-language-server
    pass
    restic
    ripgrep
    rnix-lsp
    rust-analyzer
    rustup
    shellcheck
    tmux
    tokei
    tree
  ]
  ++ (if pkgs.stdenv.isDarwin then [iterm2
                                    pinentry_mac
                                    terminal-notifier]
      else [])
  ++ work-config.packages;

  programs.git = {
    enable = true;
    userName = "Chris Sims";
    userEmail = "chris@jcsi.ms";
    attributes = ["*.gpg filter=gpg diff=gpg"];
    # difftastic doesn't yet handle gpg diffs on the command-line with
    # this config
    #difftastic.enable = true;
    aliases = {
      recent = "branch --sort=-committerdate --format=\"%(committerdate:relative)%09%(refname:short)\"";
    };
    includes = [
      {
        path = "~/code/tg/.gitconfig";
        condition = "gitdir:~/code/tg/";
      }
      {
        path = "~/dev/tg/.gitconfig";
        condition = "gitdir:~/dev/tg/";
      }
    ];
    ignores = [
      ".DS_Store"

      # Emacs
      "*.elc"
      "auto-save-list"
      "tramp"
      ".\#*"
      "*-autoloads.el"
      "*.info"
      "flycheck_*.el"
      "*-pkg.el"
      "*-autoloads.el"

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
    };
  };

  # These settings are pulled from https://github.com/drduh/YubiKey-Guide
  programs.gpg = {
    enable = true;
    settings = {
      default-key = "0x25FF041622DE3AFB";
      charset = "utf-8";
      keyid-format = "0xlong";
      use-agent = true;
    };
  };

  programs.gpg.scdaemonSettings = {
    disable-ccid = true;
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
      default-cache-ttl 600
      max-cache-ttl 7200
    '' + (if pkgs.stdenv.isDarwin then ''
      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    '' else
      "");

  home.sessionPath = ["$HOME/bin"
                      "$HOME/go/bin"
                      "$HOME/.cargo/bin"] ++
  (if pkgs.stdenv.isDarwin then
    ["/opt/homebrew/bin"
     "/opt/homebrew/sbin"]
   else []);

  home.sessionVariables = {
    CLICOLOR = 1;
    EDITOR = "$HOME/bin/e";
    VISUAL = "$HOME/bin/ec";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
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

  home.file.".aspell.conf".text = ''
    data-dir ${home.homeDirectory}/.nix-profile/lib/aspell
  '';

  home.file.".psqlrc".text = ''
    \set COMP_KEYWORD_CASE upper
    \x auto
    \pset null ¤
  '';

  home.file."bin/check-nix-apps" = {
    source = ./files/check-nix-apps;
    executable = true;
  };

  home.file.".emacs.d" = {
    source = ./files/emacs.d;
    recursive = true;
  };

  home.file.".tmux.conf".source = ./files/tmux.conf;
  home.file.".authinfo.gpg".source = ./files/authinfo.gpg;
  home.file.".functions/c.bash".source = ./files/c.bash;
  home.file.".functions/_c.bash".source = ./files/_c.bash;

  # Set up bash
  programs.bash = (import ./bash.nix { bash-completion = pkgs.bash-completion; });

  programs.bat = {
    enable = true;
    config.theme = "Monokai Extended";
  };

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.skim = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.starship =  {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
      java.disabled = true;
      nodejs.disabled = true;
      python.disabled = true;
    };
  };

  # This helps bash-completion work, since bash-completion will look here for
  # other installed completions. Other packages that include bash completion
  # scripts will link them here.
  # N.B. this only works on Linux...
  #xdg.systemDirs.data = [ "~/.nix-profile/share" ];

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
