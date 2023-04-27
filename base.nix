# This repo is cloned at $HOME/.config/nixpkgs to work with home-manager.
{ config
, pkgs
, lib
, system
, specialArgs
, ...
}:
let
  lein_jdk11 = pkgs.leiningen.override {
    jdk = pkgs.jdk11;
  };
in
rec {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = specialArgs.username;
  home.homeDirectory = specialArgs.homedir;
  home.packages =
    (lib.attrValues specialArgs.extraPackages)
    ++ [
      lein_jdk11
    ]
    ++ (with pkgs; [
      alejandra
      aspell
      aspellDicts.en
      bashInteractive
      bash-completion
      clojure-lsp
      clojure
      fd
      git
      gnupg
      htop
      iosevka-comfy.comfy
      jdk11
      jq
      languagetool
      neil
      (nerdfonts.override { fonts = [ "Hack" ]; })
      nixpkgs-fmt
      nix-diff
      nix-tree
      nodePackages.bash-language-server
      pass
      ripgrep
      rnix-lsp
      rust-analyzer
      rustup
      shellcheck
      texinfo # Used by borg to build docs
      tmux
      tokei
      tree
      tree-sitter
      vulnix
      xz
    ]);

  programs.git = {
    enable = true;
    userName = "Chris Sims";
    userEmail = "chris@jcsi.ms";
    #attributes = ["*.gpg filter=gpg diff=gpg"];
    # difftastic doesn't yet handle gpg diffs on the command-line with
    # this config
    #difftastic.enable = true;
    aliases = {
      recent = "branch --sort=-committerdate --format=\"%(committerdate:relative)%09%(refname:short)\"";
    };
    includes = [
      {
        path = "~/code/patch/.gitconfig";
        condition = "gitdir:~/code/patch/";
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
      "$HOME/code/work/patch/bin"
      "$HOME/.local/bin" # pipx install path
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

  home.file.".emacs.d" = {
    source = ./files/emacs.d;
    recursive = true;
  };

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

  home.file.".tmux.conf".source = ./files/tmux.conf;
  home.file.".authinfo.gpg".source = ./files/authinfo.gpg;
  home.file.".functions/c.bash".source = ./files/c.bash;
  home.file.".functions/_c.bash".source = ./files/_c.bash;

  # Set up bash
  programs.bash = import ./bash.nix { bash-completion = pkgs.bash-completion; };

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
    #tmux.enableShellIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
      java.disabled = true;
      nodejs.disabled = true;
      python.disabled = true;
      jobs.disabled = true;
    };
  };

  programs.alacritty = {
    enable = true;
    package = specialArgs.unstable_pkgs.alacritty;
    settings = {
      window = {
        option_as_alt = "OnlyLeft";
        padding = {
          x = 2;
          y = 2;
        };
      };
      scrolling.history = 20000;
      font = {
        size = 12;
        normal.family = "Hack Nerd Font";
        bold.family = "Hack Nerd Font";
        italic.family = "Hack Nerd Font";
        bold_italic.family = "Hack Nerd Font";
      };
      mouse_bindings = [
        {
          mouse = "Middle";
          mode = "~Vi";
          action = "PasteSelection";
        }
      ];
      key_bindings = [
        {
          key = "PageUp";
          mods = "Shift";
          mode = "~Alt";
          action = "ScrollPageUp";
        }
        {
          key = "PageDown";
          mods = "Shift";
          mode = "~Alt";
          action = "ScrollPageDown";
        }
        {
          key = "K";
          mods = "Command";
          mode = "~Vi|~Search";
          chars = "\x0c";
        }
        {
          key = "K";
          mods = "Command";
          mode = "~Vi|~Search";
          action = "ClearHistory";
        }
        {
          key = "Key0";
          mods = "Command";
          action = "ResetFontSize";
        }
        {
          key = "Equals";
          mods = "Command";
          action = "IncreaseFontSize";
        }
        {
          key = "Plus";
          mods = "Command";
          action = "IncreaseFontSize";
        }
        {
          key = "NumpadAdd";
          mods = "Command";
          action = "IncreaseFontSize";
        }
        {
          key = "Minus";
          mods = "Command";
          action = "DecreaseFontSize";
        }
        {
          key = "NumpadSubtract";
          mods = "Command";
          action = "DecreaseFontSize";
        }
        {
          key = "V";
          mods = "Command";
          action = "Paste";
        }
        {
          key = "C";
          mods = "Command";
          action = "Copy";
        }
        {
          key = "C";
          mods = "Command";
          mode = "Vi|~Search";
          action = "ClearSelection";
        }
        {
          key = "H";
          mods = "Command";
          action = "Hide";
        }
        {
          key = "H";
          mods = "Command|Alt";
          action = "HideOtherApplications";
        }
        {
          key = "M";
          mods = "Command";
          action = "Minimize";
        }
        {
          key = "Q";
          mods = "Command";
          action = "Quit";
        }
        {
          key = "W";
          mods = "Command";
          action = "Quit";
        }
        {
          key = "N";
          mods = "Command";
          action = "CreateNewWindow";
        }
        {
          key = "F";
          mods = "Command|Control";
          action = "ToggleFullscreen";
        }
        {
          key = "F";
          mods = "Command";
          mode = "~Search";
          action = "SearchForward";
        }
        {
          key = "B";
          mods = "Command";
          mode = "~Search";
          action = "SearchBackward";
        }
      ];
      draw_bold_text_with_bright_colors = true;
      colors = {
        primary = {
          background = "#282a36";
          foreground = "#eff0eb";
        };
        cursor.cursor = "#97979b";
        selection = {
          text = "#282a36";
          background = "#feffff";
        };
        normal = {
          black = "#282a36";
          red = "#ff5c57";
          green = "#5af78e";
          yellow = "#f3f99d";
          blue = "#57c7ff";
          magenta = "#ff6ac1";
          cyan = "#9aedfe";
          white = "#f1f1f0";
        };
        bright = {
          black = "#686868";
          red = "#ff5c57";
          green = "#5af78e";
          yellow = "#f3f99d";
          blue = "#57c7ff";
          magenta = "#ff6ac1";
          cyan = "#9aedfe";
          white = "#eff0eb";
        };
      };
    };
  };

  programs.vscode = {
    enable = false;
    package = specialArgs.unstable_pkgs.vscode;
  };

  # launchd.agents."org-roam.sync" = {
  #   enable = true;
  #   config = {
  #     Label = "org-roam.sync";
  #     Program = specialArgs.homedir/bin/org-roam-sync;
  #     StandardErrorPath = /tmp/org-roam.sync.stderr;
  #     StandardOutPath = /tmp/org-roam.sync.stdout;
  #     StartCalendarInterval = [{
  #       Hour = 16;
  #       Minute = 0;
  #     }];
  #     WorkingDirectory = "${specialArgs.homedir}}/org-roam";
  #   };
  # };

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
