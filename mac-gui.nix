{ pkgs, specialArgs, ... }:
let unstable = specialArgs.unstable_pkgs;
in
{
  home.packages = with pkgs; [
    unstable.emacs
    unstable.iterm2
    pinentry_mac
    terminal-notifier
  ];
}
