{ pkgs, specialArgs, ... }:
{
  home.packages = with pkgs; [
    emacs-unstable
    iterm2
    pinentry_mac
    terminal-notifier
  ];
}
