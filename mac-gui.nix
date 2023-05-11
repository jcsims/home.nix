{ pkgs, specialArgs, ... }:
{
  home.packages = with pkgs; [
    emacs
    iterm2
    pinentry_mac
    terminal-notifier
  ];
}
