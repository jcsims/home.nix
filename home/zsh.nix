{ pkgs, ls-colors }:

{
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    #enableVteIntegration = true;
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
    initExtraBeforeCompInit = ''
      eval $(${pkgs.coreutils}/bin/dircolors -b ${ls-colors}/share/LS_COLORS)
      ${builtins.readFile ./pre-compinit.zsh}
      '';
    initExtra = builtins.readFile ./post-compinit.zsh;

    # plugins = [
    #   {
    #     name = "zsh-autosuggestions";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "zsh-users";
    #       repo = "zsh-autosuggestions";
    #       rev = "v0.6.3";
    #       sha256 = "1h8h2mz9wpjpymgl2p7pc146c1jgb3dggpvzwm9ln3in336wl95c";
    #     };
    #   }
    #   {
    #     name = "zsh-syntax-highlighting";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "zsh-users";
    #       repo = "zsh-syntax-highlighting";
    #       rev = "be3882aeb054d01f6667facc31522e82f00b5e94";
    #       sha256 = "0w8x5ilpwx90s2s2y56vbzq92ircmrf0l5x8hz4g1nx3qzawv6af";
    #     };
    #   }
    # ];

    sessionVariables = rec {
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=3";

      EDITOR = "e";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;
    };
  }
