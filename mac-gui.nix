{ pkgs, specialArgs, ... }:
{
  home.packages = with pkgs; [
    emacsUnstable
    iterm2
    pinentry_mac
    terminal-notifier
  ];
}
