{ pkgs }:

{
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    cdpath = ["$HOME/code"
              "$HOME/code/tg"
              "$HOME/dev"
              "$HOME/dev/tg"];
    defaultKeymap = "emacs";
    history = {
      ignoreDups = true;
      size = 50000;
      save = 50000;
    };
    shellAliases = import ./alias.nix;
    initExtraBeforeCompInit = builtins.readFile ./pre-compinit.zsh;
    initExtra = builtins.readFile ./post-compinit.zsh;

    sessionVariables = rec {
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=3";

      EDITOR = "e";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;
    };
  }
