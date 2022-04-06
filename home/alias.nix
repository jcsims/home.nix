{
  cat = "bat";
  grep = "grep --color=auto";
  ls = "ls --color=auto";
  stay-awake = "caffeinate -di";
  tree = "tree -C";
  alert = "terminal-notifier -activate 'com.googlecode.iterm2' -message \"$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')\"";

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
}
