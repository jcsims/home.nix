{ config, pkgs, ... }:

let
  LS_COLORS = pkgs.fetchgit {
    url = "https://github.com/trapd00r/LS_COLORS";
    rev = "6fb72eecdcb533637f5a04ac635aa666b736cf50";
    sha256 = "0czqgizxq7ckmqw9xbjik7i1dfwgc1ci8fvp1fsddb35qrqi857a";
  };
  ls-colors = pkgs.runCommand "ls-colors" { } ''
    mkdir -p $out/bin $out/share
    ln -s ${pkgs.coreutils}/bin/ls $out/bin/ls
    ln -s ${pkgs.coreutils}/bin/dircolors $out/bin/dircolors
    cp ${LS_COLORS}/LS_COLORS $out/share/LS_COLORS
  '';

  shell-prompt = pkgs.callPackage ./home/shell-prompt { };

  # pinentry = pkgs.fetchFromGitHub {
  #   owner = "GPGTools";
  #   repo = "pinentry";
  #   rev = "b7195e9d4c098ea315e18ade3b4dab210492fadf";
  #   sha256 = "0";
  # };

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
    emacs
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
    pinentry_mac # Builds an ancient version
    # To pin this version of postgres: nix-env --set-flag keep true postgresql
    postgresql_13
    redis
    ripgrep
    rust-analyzer
    rustup
    shellcheck
    terminal-notifier
    tmux
    tokei
    tree
  ] ++ [ ls-colors shell-prompt ];

  programs.git = {
    enable = true;
    userName = "Chris Sims";
    userEmail = "chris@jcsi.ms";
    difftastic.enable = true;
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
    };
  };

  # These settings are pulled from https://github.com/drduh/YubiKey-Guide
  programs.gpg = {
    enable = true;
    settings = {
      default-key = "0xBB759FA6197A3272";
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
      throw-keyids = true;
    };
  };

  programs.gpg.scdaemonSettings = {
    disable-ccid = true;
  };

  # TODO: This is an ancient version of pinentry-mac. Should look into
  # a newer one at some point.
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
                      "$HOME/go/bin"];

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

  # programs.bash = import ./home/bash.nix;

  programs.zsh = (import ./home/zsh.nix {pkgs = pkgs; ls-colors = ls-colors;});

  # programs.fish = {
  #   enable = true;

  # };

  programs.bat = {
    enable = true;
    config.theme = "gruvbox-dark";
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.skim = {
    enable = true;
    enableZshIntegration = true;
  };

  # starship isn't building properly at the moment.
  # programs.starship =  {
  #   enable = true;
  #   enableZshIntegration = true;
  #   settings = {
  #     add_newline = false;
  #     java.disabled = true;
  #     nodejs.disable = true;
  #     python.disabled = true;
  #   };
  # };

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
