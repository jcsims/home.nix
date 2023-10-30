{ config
, pkgs
, lib
, system
, specialArgs
, alacritty-themes
, ...
}:
let
  alacritty-themes = pkgs.fetchFromGitHub {
    owner = "alacritty";
    repo = "alacritty-theme";
    rev = "914f463390b660e99731f93a6ad9493918cd5d13";
    sha256 = "sha256-eePvWNTpZVgRp4ql/UCWudtvnuvVKCDHB+sYKeHudM8=";
  };
in
rec {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = specialArgs.username;
  home.homeDirectory = specialArgs.homedir;
  home.packages =
    (lib.attrValues specialArgs.extraPackages)
    ++ (with pkgs; [
      alejandra
      aspell
      aspellDicts.en
      bashInteractive
      bash-completion
      cachix
      clojure-lsp
      clojure
      complete-alias # Aliases want completion, too!
      fd
      git
      gnupg
      gnuplot # Used by maelstrom
      go_1_19
      gopls
      htop
      jdk17
      jq
      languagetool
      neil
      (nerdfonts.override { fonts = [ "Hack" ]; })
      nixpkgs-fmt
      nix-diff
      nix-tree
      nodePackages.bash-language-server
      pass
      pkg-config # jinx module build
      ripgrep
      rnix-lsp
      rustup
      shellcheck
      texinfo # Used by borg to build docs
      tmux
      tokei
      tree
      tree-sitter
      vulnix
      watch
      xz
    ]);

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
      default-key = "0x25FF041622DE3AFB";
      charset = "utf-8";
      keyid-format = "0xlong";
      use-agent = true;
    };
  };

  programs.gpg.scdaemonSettings = {
    disable-ccid = true;
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
        pinentry-program ${pkgs.pinentry-qt}bin/pinentry-qt
      ''
    );

  home.sessionPath =
    [
      "$HOME/bin"
      "$HOME/go/bin"
      "$HOME/.cargo/bin"
    ]
    ++ (
      if pkgs.stdenv.isDarwin
      then [
        "/opt/homebrew/bin"
        "/opt/homebrew/sbin"
      ]
      else [ ]
    );

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

  # home.file.".emacs.d" = {
  #   source = ./files/emacs.d;
  #   recursive = true;
  # };

  home.file.".aspell.conf".text = ''
    data-dir ${specialArgs.homedir}/.nix-profile/lib/aspell
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

  home.file.".config/clojure-lsp/config.edn".text = ''
    {:dependency-scheme  "jar"
     :java {:jdk-source-uri "file://${specialArgs.homedir}/.nix-profile/lib/src.zip"}}

  '';

  home.file.".tmux.conf".source = ./files/tmux.conf;
  home.file.".authinfo.gpg".source = ./files/authinfo.gpg;
  home.file.".functions/c.bash".source = ./files/c.bash;
  home.file.".functions/_c.bash".source = ./files/_c.bash;

  # Set up bash
  programs.bash = import ./bash.nix { inherit pkgs; };

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
    # This fixes the broken screen clearing that was added here: https://github.com/lotabout/skim/pull/472
    defaultOptions = [ "--no-clear-start" ];
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
      git_status.disabled = true;
      java.disabled = true;
      nodejs.disabled = true;
      python.disabled = true;
      gcloud.disabled = true;
      kubernetes = {
        context_aliases = {
          k8s-ue-1 = "prod";
          k8s-dev-1 = "dev";
        };
        detect_folders = [ "k8s" ];
        disabled = false;
      };
    };
  };

  home.file.".config/alacritty/alacritty.yml".source = ./files/alacritty.yml;
  home.file.".config/alacritty/themes".source = alacritty-themes;
  programs.alacritty.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

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
