# This repo is cloned at $HOME/.config/nixpkgs to work with home-manager.
{ config, pkgs, ... }:

let
  appliance-config-exists = builtins.pathExists /Users/jcsims/code/tg/appliance;

  appliance-config = if appliance-config-exists then import /Users/jcsims/code/tg/appliance { }
                     else {};
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
    bashInteractive
    bash-completion
    chezmoi
    # clojure-lsp # not built for aarch64 yet (ever?)
    clojure
    cmake # For building libgit
    #emacs
    fd
    git
    gnupg
    go
    gopls
    htop
    jdk11
    jq
    nixpkgs-fmt
    nix-tree
    pass
    pinentry_mac
    # To pin this version of postgres: nix-env --set-flag keep true postgresql
    postgresql_13
    redis
    ripgrep
    rust-analyzer
    rustup
    shellcheck
    sshuttle
    terminal-notifier
    tmux
    tokei
    tree
  ] ++ [ # ls-colors
         # shell-prompt
  ] ++ (if appliance-config-exists then with appliance-config; [ tgRash tg-signed-json tg-update-client ] else [ ]);

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
    extraConfig = {
      core.excludesFile = "~/.gitignore";
      credential.helper = "osxkeychain";
      fetch.prune = true;
      init.defaultBranch = "main";
      magit.hideCampaign = true;
      pull.rebase = true;
      rebase.autostach = true;
      status.submoduleSummary = true;
      diff.gpg.textconv = "gpg --no-tty --decrypt";
    };
  };

  # These settings are pulled from https://github.com/drduh/YubiKey-Guide
  programs.gpg = {
    enable = true;
    settings = {
      default-key = "0x25FF041622DE3AFB";
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      charset = "utf-8";
      fixed-list-mode = true;
      no-comments = true;
      no-emit-version = true;
      no-greeting = true;
      keyid-format = "0xlong";
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      with-fingerprint = true;
      require-cross-certification = true;
      no-symkey-cache = true;
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
                      "/opt/homebrew/bin"
                      "/opt/homebrew/sbin"
                      "$HOME/go/bin"
                      "$HOME/.cargo/bin"];

  home.sessionVariables = {
    CLICOLOR = 1;
    EDITOR = "$HOME/bin/e";
    VISUAL = "$HOME/bin/ec";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };

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
