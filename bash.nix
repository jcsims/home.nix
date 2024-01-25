{pkgs}: {
  enable = true;
  historyControl = ["erasedups"];
  historyFile = "$HOME/.bash_history";
  historyFileSize = 100000;
  historyIgnore = ["bg" "clear" "exit" "fg" "history" "ls"];
  # env vars, if any needed outside of home.sessionVariables
  # sessionVariables = {};
  shellAliases =
    {
      reload = "exec bash";
      stay-awake = "caffeinate -di";

      # Git aliases
      gl = "git log --graph --abbrev-commit --date=relative --pretty=format:'%C(bold blue)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
      gp = "git push origin HEAD";
      gpl = "git pull --rebase --prune";
      gd = "git diff";
      gdc = "git diff --cached";
      gc = "git commit";
      gco = "git checkout";
      ga = "git add";
      gs = "git status -sb";

      # Kubernetes
      k = "kubectl";
      kns = "kubectl config set-context --current --namespace ";
    }
    // (
      if pkgs.stdenv.isDarwin
      then {alert = "${pkgs.terminal-notifier}/bin/terminal-notifier -activate 'com.googlecode.iterm2' -message \"$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')\"";}
      else {}
    );

  # Code for initializing interactive shells
  initExtra = ''
    # Perform file completion in a case insensitive fashion
    bind "set completion-ignore-case on"

    # Treat hyphens and underscores as equivalent
    bind "set completion-map-case on"

    # Display matches for ambiguous patterns at first tab press
    bind "set show-all-if-ambiguous on"

    # Enable incremental history search with up/down arrows (also Readline goodness)
    # Learn more about this here: http://codeinthehole.com/writing/the-most-important-command-line-tip-incremental-history-searching-with-inputrc/
    bind '"\e[A": history-search-backward'
    bind '"\e[B": history-search-forward'
    bind '"\e[C": forward-char'
    bind '"\e[D": backward-char'
    bind '"\e\e[D": backward-word'
    bind '"\e\e[C": forward-word'

    # Attempt to add completions for _all_ aliases
    source ${pkgs.complete-alias}/bin/complete_alias
    complete -F _complete_alias "''${!BASH_ALIASES[@]}"

    # Increase the count of open files allowed (default is 256 on macOS)
    ulimit -Sn 4096
  '';

  # extra stuff in .bashrc
  bashrcExtra = ''
    if [[ -a ~/.localrc ]]
    then
      source "$HOME/.localrc"
    fi

    # This helps bash-completion work, since bash-completion will look here for
    # other installed completions. Other packages that include bash completion
    # scripts will link them here.
    export XDG_DATA_DIRS="$HOME/.nix-profile/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

    for f in $HOME/.functions/*; do source "$f"; done
  '';
}
