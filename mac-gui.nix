{pkgs, ...}: {
  home.packages = with pkgs; [
    iterm2
    pinentry_mac
    terminal-notifier
  ];
}
